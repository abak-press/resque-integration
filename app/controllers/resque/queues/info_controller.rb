module Resque
  module Queues
    class InfoController < ActionController::Metal
      def show
        self.response_body = {data: Resque.queues_info.data}.to_json
      end
    end
  end
end
