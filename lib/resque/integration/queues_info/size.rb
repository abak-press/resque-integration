module Resque
  module Integration
    class QueuesInfo
      class Size
        def initialize(config)
          @config = config
        end

        def size(queue)
          Resque.size(queue) || 0
        end

        def overall
          max = 0

          Resque.queues.each do |queue|
            size = Resque.size(queue).to_i
            next if size < threshold(queue)
            max = size if size > max
          end

          max
        end

        private

        def threshold(queue)
          @config.max_size(queue)
        end
      end
    end
  end
end
