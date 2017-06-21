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
    #
    #     def self.execute(*args)
    #       meta = get_meta
    #
    #       heavy_lifting_work do
    #         meta[:count] += 1
    #       end
    #     end
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
    #   end
    module Priority
      def self.included(base)
        base.extend(Resque::Plugins::Meta)
        base.singleton_class.prepend(Enqueue)
      end

      module Enqueue
        def enqueue(*args)
          priority = args.last.delete(:queue_priority) { :normal }.to_sym

          priority_queue = priority == :normal ? queue : "#{queue}_#{priority}".to_sym

          if unique?
            enqueue_to(priority_queue, *args)
          else
            Resque::Plugins::Meta::Metadata.new('meta_id' => meta_id(args), 'job_class' => to_s).tap do |meta|
              meta.save
              Resque.enqueue_to(priority_queue, self, meta.meta_id, *args)
            end
          end
        end

        def perform(meta_id, *args)
          @meta_id = meta_id

          execute(*args)
        end

        def meta
          get_meta(@meta_id)
        end
      end
    end
  end
end
