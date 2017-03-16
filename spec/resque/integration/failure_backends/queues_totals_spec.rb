require 'spec_helper'

describe Resque::Integration::FailureBackends::QueuesTotals do
  let(:failure) { double('UnbelievableError') }
  let(:worker) { double('Worker') }
  let(:payload) { double('Payload') }

  describe '#save' do
    let(:queue) { 'images' }
    let(:backend) { described_class.new(failure, worker, queue, payload) }

    before { stub_const('Resque::Integration::FailureBackends::QueuesTotals::MAX_COUNTER_VALUE', 3) }

    it 'increments failures count for specified queue' do
      expect do
        2.times { backend.save }
      end.to change { described_class.count(queue) }.from(0).to(2)
    end

    context 'when counter overflows' do
      it 'resets failures count for specified queue to 1' do
        expect do
          3.times { backend.save }
        end.to change { described_class.count(queue) }.from(0).to(1)
      end
    end
  end

  describe '.count' do
    let(:images_queue) { 'images' }
    let(:products_queue) { 'products' }
    let(:images_failure_backend) { described_class.new(failure, worker, images_queue, payload) }
    let(:products_failure_backend) { described_class.new(failure, worker, products_queue, payload) }

    before do
      2.times { images_failure_backend.save }
      3.times { products_failure_backend.save }
    end

    context 'with specified queue' do
      it 'returns failures count for specified queue' do
        expect(described_class.count(images_queue)).to eq(2)
        expect(described_class.count(products_queue)).to eq(3)
      end
    end

    context 'with queue which has no failures' do
      it 'returns 0' do
        expect(described_class.count('not_failed')).to eq(0)
      end
    end

    context 'without specified queue' do
      it 'returns aggregated failures count from all queues' do
        expect(described_class.count).to eq(5)
      end
    end
  end

  describe '.queues' do
    context 'when has failures data' do
      let(:images_queue) { 'images' }
      let(:products_queue) { 'products' }

      before do
        described_class.new(failure, worker, images_queue, payload).save
        described_class.new(failure, worker, products_queue, payload).save
      end

      it 'returns names of failed queues' do
        expect(described_class.queues).to match_array([images_queue, products_queue])
      end
    end

    context 'when does not have failures data' do
      it { expect(described_class.queues).to be_empty }
    end
  end

  describe '.clear' do
    let(:images_queue) { 'images' }
    let(:products_queue) { 'products' }

    before do
      described_class.new(failure, worker, images_queue, payload).save
      described_class.new(failure, worker, products_queue, payload).save
    end

    context 'with specified queue' do
      it 'deletes counter data for specified queue' do
        expect { described_class.clear(products_queue) }.to change { described_class.count }.from(2).to(1)
        expect(described_class.count(images_queue)).to eq(1)
        expect(described_class.count(products_queue)).to eq(0)
      end
    end

    context 'without specified queue' do
      it 'deletes counter data for all queues' do
        expect { described_class.clear }.to change { described_class.count }.from(2).to(0)
        expect(described_class.count(images_queue)).to eq(0)
        expect(described_class.count(products_queue)).to eq(0)
      end
    end
  end
end
