module Resque
  module Integration
    class QueuesInfo
      autoload :Age, "resque/integration/queues_info/age"
      autoload :Size, "resque/integration/queues_info/size"
      autoload :Config, "resque/integration/queues_info/config"

      def initialize(options)
        @config = Config.new(options.fetch(:config))
        @size = Size.new(@config)
        @age = Age.new(@config)
      end

      def age_for_queue(queue)
        @age.time(queue)
      end

      def age_overall
        @age.overall
      end

      def size_for_queue(queue)
        @size.size(queue)
      end

      def size_overall
        @size.overall
      end

      def threshold_size(queue)
        @config.max_size(queue)
      end

      def threshold_age(queue)
        @config.max_age(queue)
      end

      def channel(queue)
        @config.channel(queue)
      end

      def data
        @config.data
      end
    end
  end
end
