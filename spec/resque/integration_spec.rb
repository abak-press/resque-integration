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
      class UniqueJob
        include Resque::Integration

        queue :test
        unique
      end

      it 'enqueues only one job' do
        UniqueJob.enqueue(param: 'one')

        Timecop.travel(10.hours.since) do
          UniqueJob.enqueue(param: 'one')

          expect(Resque.peek(:test, 0, 100).size).to eq(1)
        end
      end

      it 'enqueues two jobs with differ args' do
        UniqueJob.enqueue(param: 'one')

        Timecop.travel(10.hours.since) do
          UniqueJob.enqueue(param: 'two')

          expect(Resque.peek(:test, 0, 100).size).to eq(2)
        end
      end

      it 'enqueues two jobs after expire lock timeout' do
        UniqueJob.enqueue(param: 'one')

        Timecop.travel(4.days.since) do
          UniqueJob.enqueue(param: 'one')

          expect(Resque.peek(:test, 0, 100).size).to eq(2)
        end
      end
    end
  end
end
