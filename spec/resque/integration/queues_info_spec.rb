require "spec_helper"

describe Resque::Integration::QueuesInfo do
  let(:queue_info) { described_class.new(config: 'spec/fixtures/resque_queues.yml') }

  before do
    Timecop.freeze Time.current
  end

  after do
    Timecop.return
  end

  context 'age' do
    before do
      allow(Resque).to receive(:workers).and_return(workers)
    end

    context 'age_for_queue' do
      context 'when old job running' do
        let(:workers) do
          [double(job: {'run_at' => 4.hours.ago.utc.iso8601, 'queue' => 'first'}, 'idle?' => false)]
        end

        it 'returns time for job ' do
          expect(queue_info.age_for_queue('first')).to eq 4.hours.to_i
        end
      end

      context 'when job running normal time' do
        let(:workers) do
          [double(job: {'run_at' => 4.seconds.ago.utc.iso8601, 'queue' => 'first'}, 'idle?' => false)]
        end

        it 'returns time for job ' do
          expect(queue_info.age_for_queue('first')).to eq 4
        end
      end

      context 'when queue is empty' do
        let(:workers) { [] }

        it 'returns 0' do
          expect(queue_info.age_for_queue('first')).to eq 0
        end
      end

      context 'when worker is iddling' do
        let(:workers) do
          [double('idle?' => true, job: nil)]
        end

        it 'returns 0' do
          expect(queue_info.age_for_queue('first')).to eq 0
        end
      end
    end

    describe '#age_overall' do
      context 'when there is old job for its queue' do
        let(:workers) do
          [
            double(job: {'run_at' => 4.seconds.ago.utc.iso8601, 'queue' => 'second'}, 'idle?' => false),
            double(job: {'run_at' => 20.seconds.ago.utc.iso8601, 'queue' => 'first'}, 'idle?' => false)
          ]
        end

        it 'returns time for job ' do
          expect(queue_info.age_overall).to eq 20
        end
      end

      context 'when there is a several old jobs' do
        let(:workers) do
          [
            double(job: {'run_at' => 100.seconds.ago.utc.iso8601, 'queue' => 'first'}, 'idle?' => false),
            double(job: {'run_at' => 20.seconds.ago.utc.iso8601, 'queue' => 'first'}, 'idle?' => false)
          ]
        end

        it 'returns time for the oldest job ' do
          expect(queue_info.age_overall).to eq 100
        end
      end

      context 'when the is no old job' do
        let(:workers) do
          [
            double(job: {'run_at' => 4.seconds.ago.utc.iso8601, 'queue' => 'first'}, 'idle?' => false),
            double(job: {'run_at' => 2.seconds.ago.utc.iso8601, 'queue' => 'first'}, 'idle?' => false)
          ]
        end

        it 'returns 0' do
          expect(queue_info.age_overall).to eq 0
        end
      end

      context 'when old job running in unknown queue' do
        let(:workers) do
          [double(job: {'run_at' => 11.seconds.ago.utc.iso8601, 'queue' => 'unknown'}, 'idle?' => false)]
        end

        it 'checks time of job with defaults thresholds' do
          expect(queue_info.age_overall).to eq 11
        end
      end
    end
  end

  context 'size' do
    describe '#size_for_queue' do
      before do
        allow(Resque).to receive(:size).with('first').and_return(size)
      end

      context 'when too much jobs in queue' do
        let(:size) { 100 }

        it 'returns queue size' do
          expect(queue_info.size_for_queue('first')).to eq 100
        end
      end

      context 'when queue have normal size' do
        let(:size) { 1 }

        it 'returns time for job ' do
          expect(queue_info.size_for_queue('first')).to eq 1
        end
      end

      context 'when queue is empty' do
        let(:size) { nil }

        it 'returns 0' do
          expect(queue_info.size_for_queue('first')).to eq 0
        end
      end
    end

    describe '#size_overall' do
      before do
        allow(Resque).to receive(:queues).and_return(%w(first second))
        allow(Resque).to receive(:size).with('first').and_return(size_first)
        allow(Resque).to receive(:size).with('second').and_return(size_second)
      end

      context 'when there is one big queue' do
        let(:size_first) { 100 }
        let(:size_second) { nil }

        it 'returns time for job ' do
          expect(queue_info.size_overall).to eq 100
        end
      end

      context 'when there is a several old jobs' do
        let(:size_first) { 1000 }
        let(:size_second) { 200 }

        it 'returns time for the lagrest queue ' do
          expect(queue_info.size_overall).to eq 1000
        end
      end

      context 'when the is no large queus' do
        let(:size_first) { 1 }
        let(:size_second) { 2 }

        it 'returns 0' do
          expect(queue_info.size_overall).to eq 0
        end
      end

      context 'when lagre queue is unknown' do
        let(:size_first) { nil }
        let(:size_second) { 11 }

        it 'checks time of job with defaults thresholds' do
          expect(queue_info.size_overall).to eq 11
        end
      end
    end
  end
end
