module Resque
  module Integration
    # Public: job with priority queues
    #
    # Examples:
    #   class MyJob
    #     include Resque::Integration
    #
    #     queue :foo
    #     prioritized
    #
    #     def self.perform(arg)
    #       heavy_lifting_work
    #     end
    #   end
    #
    #   MyJob.enqueue_with_priority(:high, 1, another_param: 2) # enqueue job to :foo_high queue
    #   MyJob.enqueue_with_priority(:low, 1, another_param: 2) # enqueue job to :foo_low queue
    #
    #   class MyUniqueJob
    #     include Resque::Integration
    #
    #     queue :foo
    #     unique
    #     prioritized
    #
    #     def self.execute(*args)
    #       meta = get_meta
    #
    #       heavy_lifting_work do
    #         meta[:count] += 1
    #       end
    #     end
    #   end
    module Priority
      def self.extended(base)
        base.singleton_class.prepend(Overrides)
      end

      module Overrides
        # Public: enqueue job with normal priority
        #
        # Example:
        #   MyJob.enqueue(1)
        def enqueue(*args)
          enqueue_with_priority(:normal, *args)
        end

        # Public: dequeue job with priority
        #
        # Example:
        #   MyJob.dequeue(:high, 1)
        def dequeue(priority, *args)
          if unique?
            super(*args, priority)
          else
            Resque.dequeue(self, *args, priority)
          end
        end

        def perform(*args, _priority)
          super(*args)
        end
      end

      def priority?
        true
      end

      # Public: enqueue job to priority queue
      #
      # Example:
      #   MyJob.enqueue_with_priority(:high, 1)
      def enqueue_with_priority(priority, *args)
        queue = priority_queue(priority)

        if unique?
          enqueue_to(queue, *args, priority)
        else
          Resque.enqueue_to(queue, self, *args, priority)
        end
      end

      def priority_queue(priority)
        priority.to_sym == :normal ? queue : "#{queue}_#{priority}".to_sym
      end
    end
  end
end
