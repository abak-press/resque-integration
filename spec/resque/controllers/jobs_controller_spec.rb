require 'spec_helper'

describe Resque::JobsController, type: :controller, api: true do
  class MetaJob
    extend Resque::Plugins::Meta

    @queue = 'test'

    def self.perform(_meta_id); end
  end

  describe '#show' do
    context 'when id is missing' do
      before do
        get '/_job_'
      end

      it do
        expect(last_response.status).to eq 404
        expect(last_response.body).to eq '{"message":"not found"}'
      end
    end

    context 'when id is invalid' do
      before do
        get '/_job_/xx'
      end

      it do
        expect(last_response.status).to eq 404
        expect(last_response.body).to eq '{"message":"not found"}'
      end
    end

    context 'when id is correct' do
      let(:meta) { MetaJob.enqueue }
      let(:meta_id) { meta.meta_id }
      let(:body) do
        {
          enqueued_at: meta.enqueued_at,
          started_at: nil,
          finished_at: nil,
          succeeded: nil,
          failed: nil,
          progress: {num: 0, total: 1, percent: 0.0, message: nil},
          payload: nil
        }.to_json
      end

      before do
        get "/_job_/#{meta_id}"
      end

      it do
        expect(last_response.status).to eq 200
        expect(last_response.body).to eq body
      end
    end
  end
end
