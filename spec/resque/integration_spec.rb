# coding: utf-8
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

      it 'enqueues only one job' do
        UniqueJob.enqueue(1, param: 'one')

        Timecop.travel(10.hours.since) do
          UniqueJob.enqueue(1, param: 'one')

          expect(Resque.peek(:test, 0, 100).size).to eq(1)
        end
      end

      it 'enqueues two jobs with differ args' do
        UniqueJob.enqueue(1, param: 'one')

        Timecop.travel(10.hours.since) do
          UniqueJob.enqueue(1, param: 'two')

          expect(Resque.peek(:test, 0, 100).size).to eq(2)
        end
      end

      it 'enqueues two jobs after expire lock timeout' do
        UniqueJob.enqueue(1, param: 'one')

        Timecop.travel(4.days.since) do
          UniqueJob.enqueue(1, param: 'one')

          expect(Resque.peek(:test, 0, 100).size).to eq(2)
        end
      end

      describe 'unlock' do
        class UniqueJobWithBlock
          include Resque::Integration

          queue :test_with_block
          unique { |id, params| [id, params[:one], params[:two]] }

          def self.execute(id, params)
            DummyService.call
          end
        end

        around do |example|
          inline = Resque.inline
          Resque.inline = true

          example.run

          Resque.inline = inline
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
end
