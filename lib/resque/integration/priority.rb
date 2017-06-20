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
    #   MyJob.enqueue(1, another_param: 2, priority: high) # enqueue job to :for_high queue
    #   MyJob.enqueue(1, another_param: 2, priority: low) # enqueue job to :for_low queue
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
        AVALIABLE_PRIORITIES = %i(high low normal).freeze

        def enqueue(*args)
          priority = args.last.delete(:priority) { :normal }.to_sym

          unless AVALIABLE_PRIORITIES.include?(priority)
            raise ArgumentError.new("Avaliable priorities #{AVALIABLE_PRIORITIES}, :#{priority} priority given")
          end

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
