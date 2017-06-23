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
    unique do |id, params|
      [id, params["param"]]
    end

    def self.execute(id, params)
    end
  end

  describe '#enqueue' do
    it 'enqueue to priority queue' do
      JobWithPriority.enqueue_with_priority(:high, 1, param: 'one')

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

    it 'enqueue only one job' do
      meta1 = UniqueJobWithPriority.enqueue_with_priority(:high, 1, param: 'one')
      meta2 = UniqueJobWithPriority.enqueue_with_priority(:high, 1, param: 'one')

      expect(meta1.meta_id).to eq(meta2.meta_id)

      expect(Resque.size(:foo)).to eq(0)
      expect(Resque.size(:foo_low)).to eq(0)
      expect(Resque.size(:foo_high)).to eq(1)
    end
  end

  describe '#dequeue' do
    it 'dequeue simple job with high priority' do
      JobWithPriority.enqueue_with_priority(:high, 1, param: 'one')
      JobWithPriority.enqueue_with_priority(:high, 2, param: 'two')
      expect(Resque.size(:foo_high)).to eq(2)

      JobWithPriority.dequeue(:high, 1, param: 'one')
      expect(Resque.size(:foo_high)).to eq(1)
    end

    it 'dequeue unique job with high priority' do
      UniqueJobWithPriority.enqueue_with_priority(:high, 1, param: 'one')
      UniqueJobWithPriority.enqueue_with_priority(:high, 2, param: 'two')
      expect(Resque.size(:foo_high)).to eq(2)

      UniqueJobWithPriority.dequeue(:high, 1, param: 'one')
      expect(Resque.size(:foo_high)).to eq(1)
    end
  end

  describe '#perform' do
    include_context 'resque inline'

    it 'executes job' do
      expect(JobWithPriority).to receive(:execute).with(1, 'param' => 'one').once.and_call_original
      expect(JobWithPriority).to receive(:execute).with(2, 'param' => 'two').once.and_call_original

      JobWithPriority.enqueue_with_priority(:high, 1, param: 'one')
      JobWithPriority.enqueue_with_priority(:high, 2, param: 'two')
    end

    it 'executes job' do
      expect(UniqueJobWithPriority).to receive(:execute).twice.and_call_original

      UniqueJobWithPriority.enqueue_with_priority(:high, 1, param: 'one')
      UniqueJobWithPriority.enqueue_with_priority(:high, 1, param: 'one')
    end
  end
end
