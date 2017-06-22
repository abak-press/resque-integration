module Resque
  module Integration
    # Public: job with priority queues
    #
    # Examples:
    #   class MyJob
    #     include Resque::Integration
    #     include Resque::Integration::Priority
    #
    #     queue :foo
    #   end
    #
    #   MyJob.enqueue(1, another_param: 2, queue_priority: high) # enqueue job to :foo_high queue
    #   MyJob.enqueue(1, another_param: 2, queue_priority: low) # enqueue job to :foo_low queue
    #
    #   class MyUniqueJob
    #     include Resque::Integration
    #     include Resque::Integration::Priority
    #
    #     queue :foo
    #     unique
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
      def self.included(base)
        base.extend(ClassMethods)
        base.singleton_class.prepend(Enqueue)
      end

      module ClassMethods
        def priority?
          true
        end
      end

      module Enqueue
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

        def perform(*args, _priority)
          if unique?
            super(*args)
          else
            execute(*args)
          end
        end
      end
    end
  end
end
