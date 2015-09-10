# Ordered Job
#
# Ensures that only one job for a given queue
# will be running on any worker at a given time
#
# Examples:
#
#   class TestJob
#     include Resque::Integration
#
#     unique { |company_id, param1| [company_id] }
#     ordered max_iterations: 10
#
#     def self.execute(company_id, param1)
#       heavy_lifting_work
#     end
#   end
#
module Resque
  module Integration
    module Ordered
      ARGS_EXPIRATION = 1.week

      def self.extended(base)
        base.extend ClassMethods

        base.singleton_class.class_eval do
          attr_accessor :max_iterations

          alias_method_chain :enqueue, :ordered
        end
      end

      module ClassMethods
        def enqueue_with_ordered(*args)
          meta = enqueue_without_ordered(*args)

          encoded_args = Resque.encode(args)
          args_key = ordered_queue_key(meta.meta_id)
          Resque.redis.rpush(args_key, encoded_args)
          Resque.redis.expire(args_key, ARGS_EXPIRATION)

          meta
        end

        def perform(meta_id, *)
          args_key = ordered_queue_key(meta_id)
          i = 1
          while job_args = Resque.redis.lpop(args_key)
            execute(*Resque.decode(job_args))

            i += 1
            return continue if max_iterations && i > max_iterations
          end
        end

        def ordered_queue_size(meta_id)
          Resque.redis.llen(ordered_queue_key(meta_id)).to_i
        end

        def ordered_queue_key(meta_id)
          "ordered:#{meta_id}"
        end
      end
    end
  end
end
