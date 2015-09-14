require "spec_helper"

describe Resque::Integration::Ordered do
  class TestJob
    include Resque::Integration

    unique { |company_id, param1| [company_id] }
    ordered max_iterations: 2
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

    meta_id = TestJob.meta_id(1, 10)
    TestJob.perform(meta_id)
  end

  it "reenqueue job after max iterations reached" do
    TestJob.enqueue(1, 10)
    TestJob.enqueue(1, 20)
    TestJob.enqueue(1, 30)

    expect(TestJob).to receive(:execute).with(kind_of(Resque::Plugins::Meta::Metadata), 1, 10).ordered
    expect(TestJob).to receive(:execute).with(kind_of(Resque::Plugins::Meta::Metadata), 1, 20).ordered
    expect(TestJob).to_not receive(:execute).with(kind_of(Resque::Plugins::Meta::Metadata), 1, 30).ordered

    meta_id = TestJob.meta_id(1, 10)
    TestJob.perform(meta_id)
  end
end
