require 'spec_helper'

RSpec.describe Resque::Integration do
  describe '#unique?' do
    let(:job) { Class.new }
    before { job.send :include, Resque::Integration }

    subject { job }

    context 'when #unique is not called' do
      it { should_not be_unique }
    end

    context 'when #unique is called' do
      before { job.unique }

      it { should be_unique }
    end
  end

  describe 'enqueue' do
    context 'when job is uniq' do
      class DummyService
        def self.call
          # no-op
        end
      end

      class UniqueJob
        include Resque::Integration

        queue :test
        unique

        def self.execute(id, params)
          DummyService.call
        end
      end

      let(:redis) { Resque.redis }
      let(:travel_redis) do
        ->(time) do
          redis.keys.each do |key|
            ttl = redis.ttl(key)
            next if ttl <= 0

            redis.expire(key, ttl - time.to_i)
          end
        end
      end

      context 'when enqueues only one job' do
        before do
          UniqueJob.enqueue(1, param: 'one')

          travel_redis.call(10.hours)

          UniqueJob.enqueue(1, param: 'one')
        end

        it { expect(Resque.peek(:test, 0, 100).size).to eq(1) }
      end

      context 'when enqueues two jobs with differ args' do
        before do
          UniqueJob.enqueue(1, param: 'one')
          UniqueJob.enqueue(1, param: 'two')
        end

        it { expect(Resque.peek(:test, 0, 100).size).to eq(2) }
      end

      context 'when enqueues two jobs after expire lock timeout' do
        before do
          UniqueJob.enqueue(1, param: 'one')

          travel_redis.call(4.days)

          UniqueJob.enqueue(1, param: 'one')
        end

        it { expect(Resque.peek(:test, 0, 100).size).to eq(2) }
      end

      describe 'unlock' do
        include_context 'resque inline'

        class UniqueJobWithBlock
          include Resque::Integration

          queue :test_with_block
          unique { |id, params| [id, params[:one], params[:two]] }

          def self.execute(id, params)
            DummyService.call
          end
        end

        it 'unlocks uniq job with args and without block' do
          expect(DummyService).to receive(:call).twice

          UniqueJob.enqueue(1, one: 1, two: 2)
          UniqueJob.enqueue(1, one: 1, two: 2)

          expect(UniqueJob.locked?(1, one: 1, two: 2)).to eq(false)
        end

        it 'unlocks uniq job with args and block' do
          expect(DummyService).to receive(:call).twice

          UniqueJobWithBlock.enqueue(1, one: 1, two: 2)
          UniqueJobWithBlock.enqueue(1, one: 1, two: 2)

          expect(UniqueJobWithBlock.locked?(1, one: 1, two: 2)).to eq(false)
        end
      end
    end
  end

  describe 'retries' do
    context 'with default params' do
      let(:job) { Resque::Job.new(:test_retries, 'class' => 'RetriesJob', 'args' => ['meta']) }

      it do
        expect { job.perform }.to raise_error StandardError
        expect(Resque.delayed_queue_schedule_size).to eq 1
      end
    end

    context 'with custom params' do
      context 'with StandardError in exceptions' do
        let(:job) { Resque::Job.new(:test_retries, 'class' => 'RetriesStandardErrorJob', 'args' => ['meta']) }

        it do
          expect { job.perform }.to raise_error StandardError
          expect(Resque.delayed_queue_schedule_size).to eq 1
        end
      end

      context 'with ArgumentError in exceptions' do
        let(:job) { Resque::Job.new(:test_retries, 'class' => 'RetriesArgumentErrorJob', 'args' => ['meta']) }

        it do
          expect { job.perform }.to raise_error StandardError
          expect(Resque.delayed_queue_schedule_size).to eq 0
        end
      end
    end
  end
end
