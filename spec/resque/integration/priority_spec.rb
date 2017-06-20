require 'spec_helper'

RSpec.describe Resque::Integration::Priority do
  class JobWithPriority
    include Resque::Integration
    include Resque::Integration::Priority

    queue :foo

    def self.execute(id, params)
    end
  end

  class UniqueJobWithPriority
    include Resque::Integration
    include Resque::Integration::Priority

    queue :foo
    unique

    def self.execute(id, params)
    end
  end

  describe '#enqueue' do
    it 'enqueue to priority queue' do
      meta = JobWithPriority.enqueue(1, param: 'one', priority: :high)

      expect(meta.meta_id).to be

      expect(Resque.size(:foo)).to eq(0)
      expect(Resque.size(:foo_low)).to eq(0)
      expect(Resque.size(:foo_high)).to eq(1)
    end

    it 'enqueue to default queue' do
      JobWithPriority.enqueue(1, param: 'one')

      expect(Resque.size(:foo)).to eq(1)
      expect(Resque.size(:foo_low)).to eq(0)
      expect(Resque.size(:foo_high)).to eq(0)
    end

    it 'raises error' do
      expect { JobWithPriority.enqueue(1, param: 'one', priority: :unknown) }
        .to raise_error(ArgumentError)
    end

    it 'enqueue only one job' do
      meta1 = UniqueJobWithPriority.enqueue(1, param: 'one', priority: :high)
      meta2 = UniqueJobWithPriority.enqueue(1, param: 'one', priority: :high)

      expect(meta1.meta_id).to eq(meta2.meta_id)

      expect(Resque.size(:foo)).to eq(0)
      expect(Resque.size(:foo_low)).to eq(0)
      expect(Resque.size(:foo_high)).to eq(1)
    end
  end

  describe '#perform' do
    include_context 'resque inline'

    it 'executes job' do
      expect(JobWithPriority).to receive(:execute).with(1, 'param' => 'one').once.and_call_original
      expect(JobWithPriority).to receive(:execute).with(2, 'param' => 'two').once.and_call_original

      JobWithPriority.enqueue(1, param: 'one', priority: :high)
      JobWithPriority.enqueue(2, param: 'two', priority: :low)
    end

    it 'executes job' do
      expect(UniqueJobWithPriority).to receive(:execute).with(1, 'param' => 'one').twice.and_call_original

      UniqueJobWithPriority.enqueue(1, param: 'one', priority: :high)
      UniqueJobWithPriority.enqueue(1, param: 'one', priority: :high)
    end
  end
end
