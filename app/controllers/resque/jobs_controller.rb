module Resque
  class JobsController < ActionController::Metal
    JOB_ID_PATTERN = /([a-f0-9]{32})/

    def show
      unless meta
        self.status = 404
        self.content_type = "application/json; charset=utf-8"
        self.response_body = '{"message":"not found"}'
        return
      end

      data = {
        enqueued_at: meta.enqueued_at,
        started_at: meta.started_at,
        finished_at: meta.finished_at,
        succeeded: meta.succeeded?,
        failed: meta.failed?,
        progress: meta.progress,
        payload: meta['payload']
      }

      self.status = 200
      self.content_type = "application/json; charset=utf-8"
      self.response_body = MultiJson.dump(data)
    end

    private

    def meta
      @meta ||= Resque::Plugins::Meta.get_meta(meta_id) if meta_id
    end

    def meta_id
      id = params[:id]
      id if JOB_ID_PATTERN =~ id
    end
  end
end
