# coding: utf-8

require 'spec_helper'

describe Resque::Integration::Continuous do
  context 'when applied to non-unique job' do
    class ContinuousJobTest
      include Resque::Integration

      queue :continuous_test
      continuous

      def self.perform(id)
        continue(id + 1)
      end
    end

    it 'should re-enqueue the job' do
      Resque.enqueue(ContinuousJobTest, 1)

      job = Resque.reserve(ContinuousJobTest.queue)
      job.should be_a(Resque::Job)
      job.payload['args'].should eq [1]
      job.perform

      job2 = Resque.reserve(ContinuousJobTest.queue)
      job2.should be_a(Resque::Job)
      job2.payload['args'].should eq [2]
    end
  end

  context 'when applied to unique job' do
    class ContinuousUniqueJobTest
      include Resque::Integration

      queue :unique_continuous_test
      continuous
      unique { |x, y| x }

      def self.execute(x, y)
        continue(x, y + 1)
      end
    end

    it 'should re-enqueue the job regardless of any locks' do
      ContinuousUniqueJobTest.enqueue(1, 1)

      job = Resque.reserve(ContinuousUniqueJobTest.queue)
      job.should be_a(Resque::Job)

      # meta prepend meta_id arg, so we just ignore it here
      job.payload['args'][1..-1].should eq [1, 1]
      job.perform

      ContinuousUniqueJobTest.should be_locked(1, 2)
      ContinuousUniqueJobTest.should be_enqueued(1, 2)

      job2 = Resque.reserve(ContinuousUniqueJobTest.queue)
      job2.should be_a(Resque::Job)
      job2.payload['args'][1..-1].should eq [1, 2]

      # clean the queue
      Resque.dequeue(ContinuousUniqueJobTest)
    end

    it 'should not finish meta' do
      meta = ContinuousUniqueJobTest.enqueue(2, 1)

      job = Resque.reserve(ContinuousUniqueJobTest.queue)
      job.perform
      meta.reload!

      meta2 = ContinuousUniqueJobTest.enqueued?(2, 2)

      meta2.started_at.should eq meta.started_at
      meta2.enqueued_at.should eq meta.enqueued_at
      meta2.data.should eq meta.data
      meta2.should be_working

      # clean the queue
      Resque.dequeue(ContinuousUniqueJobTest)
    end

    it 'should enqueue job with the same meta_id' do
      ContinuousUniqueJobTest.enqueue(3, 1)

      job1 = Resque.reserve(ContinuousUniqueJobTest.queue)
      meta1 = job1.payload['args'].first

      job1.perform

      job2 = Resque.reserve(ContinuousUniqueJobTest.queue)
      meta2 = job2.payload['args'].first

      meta1.should eq meta2
    end
  end

  context 'when called without arguments' do
    class ContinuousWithoutArgsJobTest
      include Resque::Integration

      queue :continuous_without_args_test
      continuous
      unique

      def self.execute(x)
        continue
      end
    end

    it 'should re-enqueue job with same arguments' do
      ContinuousWithoutArgsJobTest.enqueue(1)

      job = Resque.reserve(ContinuousWithoutArgsJobTest.queue)
      job.should be_a(Resque::Job)
      job.perform

      ContinuousWithoutArgsJobTest.should be_enqueued(1)
    end
  end
end