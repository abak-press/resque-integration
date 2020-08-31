require "spec_helper"

describe Resque::Integration::Ordered do
  class TestJob
    include Resque::Integration

    unique { |company_id, param1| [company_id] }
    ordered max_iterations: 2

    def self.execute(ordered_meta, arg1, arg2)
      old_meta = @meta_id
      @meta_id = ordered_meta.meta_id

      at(arg1, arg2, 'some message')

      @meta_id = old_meta
    end
  end

  class UniqueTestJob
    include Resque::Integration

    unique { |company_id, param1| [company_id] }
    ordered max_iterations: 2, unique: ->(_company_id, param1) { [param1] }
  end

  it "push args to separate queue" do
    ordered_meta1 = TestJob.enqueue(1, 10)
    ordered_meta2 = TestJob.enqueue(1, 20)

    meta_id = TestJob.meta_id(1, 10)
    args_key = TestJob.ordered_queue_key(meta_id)

    expect(TestJob).to be_enqueued(1)
    expect(TestJob.ordered_queue_size(meta_id)).to eq 2

    job_args = Resque.decode(Resque.redis.lpop(args_key))
    expect(job_args[0]).to eq ordered_meta1.meta_id

    job_args = Resque.decode(Resque.redis.lpop(args_key))
    expect(job_args[0]).to eq ordered_meta2.meta_id
  end

  it "execute jobs by each args" do
    TestJob.enqueue(1, 10)
    TestJob.enqueue(1, 20)

    expect(TestJob).to receive(:execute).with(kind_of(Resque::Plugins::Meta::Metadata), 1, 10).ordered
    expect(TestJob).to receive(:execute).with(kind_of(Resque::Plugins::Meta::Metadata), 1, 20).ordered
    expect(TestJob).to_not receive(:continue)

    meta_id = TestJob.meta_id(1, 10)
    TestJob.perform(meta_id)
    expect(TestJob.ordered_queue_size(meta_id)).to eq 0
  end

  it "reenqueue job after max iterations reached" do
    TestJob.enqueue(1, 10)
    TestJob.enqueue(1, 20)
    TestJob.enqueue(1, 30)
    TestJob.enqueue(1, 40)

    expect(TestJob).to receive(:execute).with(kind_of(Resque::Plugins::Meta::Metadata), 1, 10).ordered
    expect(TestJob).to receive(:execute).with(kind_of(Resque::Plugins::Meta::Metadata), 1, 20).ordered
    expect(TestJob).to_not receive(:execute).with(kind_of(Resque::Plugins::Meta::Metadata), 1, 30).ordered
    expect(TestJob).to_not receive(:execute).with(kind_of(Resque::Plugins::Meta::Metadata), 1, 40).ordered
    expect(TestJob).to receive(:continue)

    meta_id = TestJob.meta_id(1, 10)
    TestJob.perform(meta_id)
    expect(TestJob.ordered_queue_size(meta_id)).to eq 2
  end

  it 'save ordered meta' do
    ordered_meta_id = TestJob.enqueue(1, 10).meta_id
    meta_id = TestJob.meta_id(1, 10)
    TestJob.perform(meta_id)
    ordered_meta = TestJob.get_meta(ordered_meta_id)

    expect(ordered_meta).to be_finished
    expect(ordered_meta.progress).to eq(num: 1, total: 10, percent: 10, message: 'some message')
  end

  context 'uniqueness' do
    it 'perform with unique args only once' do
      UniqueTestJob.enqueue(1, 10)
      UniqueTestJob.enqueue(1, 20)
      UniqueTestJob.enqueue(1, 10)

      expect(UniqueTestJob).to receive(:execute).once.with(kind_of(Resque::Plugins::Meta::Metadata), 1, 10).ordered
      expect(UniqueTestJob).to receive(:execute).once.with(kind_of(Resque::Plugins::Meta::Metadata), 1, 20).ordered
      expect(UniqueTestJob).to_not receive(:continue)

      meta_id = UniqueTestJob.meta_id(1, 10)
      UniqueTestJob.perform(meta_id)
      expect(UniqueTestJob.ordered_queue_size(meta_id)).to eq 0
      expect(UniqueTestJob.uniqueness.size(meta_id)).to eq 0
    end

    it 'enqueue unique jobs with equal meta' do
      meta = UniqueTestJob.enqueue(1, 10)
      expect(meta.meta_id).to eq UniqueTestJob.enqueue(1, 10).meta_id
      expect(meta.meta_id).to_not eq UniqueTestJob.enqueue(1, 20).meta_id
    end
  end

  describe '#in_ordered_queue?' do
    before do
      allow(TestJob).to receive(:rand).and_return(123)

      Timecop.freeze
    end

    it do
      TestJob.enqueue(1, 10)
      TestJob.enqueue(1, 20)

      expect(TestJob.in_ordered_queue?(1, 10)).to be_instance_of(Resque::Plugins::Meta::Metadata)
      expect(TestJob.in_ordered_queue?(1, 10).meta_id).to eq TestJob.ordered_meta_id([1, 10])
      expect(TestJob.in_ordered_queue?(1, 20)).to be_instance_of(Resque::Plugins::Meta::Metadata)
      expect(TestJob.in_ordered_queue?(1, 20).meta_id).to eq TestJob.ordered_meta_id([1, 20])
      expect(TestJob.in_ordered_queue?(1, 30)).to be_falsey
    end

    context 'when some complex arg' do
      let(:complex_arg) { [Integer, {a: 1, 'b' => '2'}, 10] }

      it do
        expect(TestJob.in_ordered_queue?(1, complex_arg)).to be_falsey

        TestJob.enqueue(1, complex_arg)

        expect(TestJob.in_ordered_queue?(1, complex_arg)).to be_instance_of(Resque::Plugins::Meta::Metadata)
        expect(TestJob.in_ordered_queue?(1, complex_arg).meta_id).to eq TestJob.ordered_meta_id([1, complex_arg])

        TestJob.perform(TestJob.meta_id(1, complex_arg))

        expect(TestJob.in_ordered_queue?(1, complex_arg)).to be_falsey
      end
    end

    after { Timecop.return }
  end
end
