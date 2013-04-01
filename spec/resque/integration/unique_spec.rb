# coding: utf-8

require 'spec_helper'

describe Resque::Integration::Unique, '#meta_id, #lock' do
  let(:job) { Class.new }
  before { job.extend Resque::Integration::Unique }

  context 'when unique arguments are not set' do
    it 'returns same results when equal arguments given' do
      job.meta_id('a', 'b').should eq job.meta_id('a', 'b')
      job.lock(nil, 'a', 'b').should eq job.lock(nil, 'a', 'b')
    end

    it 'returns different results when different arguments given' do
      job.meta_id('a', 'b').should_not eq job.meta_id('a', 'c')
      job.lock(nil, 'a', 'b').should_not eq job.lock(nil, 'a', 'c')
    end
  end

  context 'when unique arguments are set' do
    # mark second argument as unique
    before { job.lock_on &->(a, b) { b } }

    it 'returns same results when equal arguments given' do
      job.meta_id('a', 'b').should eq job.meta_id('a', 'b')
      job.lock(nil, 'a', 'b').should eq job.lock(nil, 'a', 'b')

      job.meta_id('a', 'b').should eq job.meta_id('c', 'b')
      job.lock(nil, 'a', 'b').should eq job.lock(nil, 'c', 'b')
    end

    it 'returns different results when different arguments given' do
      job.meta_id('a', 'b').should_not eq job.meta_id('a', 'c')
      job.lock(nil, 'a', 'b').should_not eq job.lock(nil, 'a', 'c')
    end
  end
end

describe Resque::Integration::Unique, '#enqueue, #enqueued?' do
  class JobEnqueueTest
    extend Resque::Integration::Unique

    @queue = :queue1
  end

  it 'returns false when job is not enqueued' do
    JobEnqueueTest.should_not be_enqueued(0)
  end

  it 'returns new meta when job is enqueued' do
    JobEnqueueTest.should_receive(:enqueue_without_check).and_call_original

    meta = JobEnqueueTest.enqueue(1)
    meta.should be_a Resque::Plugins::Meta::Metadata

    JobEnqueueTest.should be_enqueued(1)
  end

  it 'returns the same meta if job already in queue' do
    meta1 = JobEnqueueTest.enqueue(2)
    meta2 = JobEnqueueTest.enqueue(2)

    meta1.meta_id.should eq meta2.meta_id
    meta1.enqueued_at.should eq meta2.enqueued_at

    JobEnqueueTest.should be_enqueued(2)
  end
end

describe Resque::Integration::Unique, '#dequeue' do
  class JobDequeueTest
    extend Resque::Integration::Unique

    @queue = :queue2
  end

  it 'dequeues and unlocks job if job is not in work now' do
    JobDequeueTest.enqueue(1)
    JobDequeueTest.should be_enqueued(1)

    JobDequeueTest.dequeue(1)
    JobDequeueTest.should_not be_enqueued(1)
    JobDequeueTest.should_not be_locked(1)
  end
end