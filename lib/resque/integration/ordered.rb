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
#     def self.execute(meta, company_id, param1)
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

          ordered_meta = Resque::Plugins::Meta::Metadata.new('meta_id' => ordered_meta_id(args), 'job_class' => self)
          ordered_meta.save

          args.unshift(ordered_meta.meta_id)
          encoded_args = Resque.encode(args)
          args_key = ordered_queue_key(meta.meta_id)

          Resque.redis.rpush(args_key, encoded_args)
          Resque.redis.expire(args_key, ARGS_EXPIRATION)

          ordered_meta
        end

        def perform(meta_id, *)
          args_key = ordered_queue_key(meta_id)
          i = 1
          while job_args = Resque.redis.lpop(args_key)
            job_args = Resque.decode(job_args)
            ordered_meta = get_meta(job_args.shift)
            ordered_meta.start!

            begin
              execute(ordered_meta, *job_args)
            rescue Exception
              ordered_meta.fail!
              raise
            end

            ordered_meta.finish!

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

        def ordered_meta_id(args)
          Digest::SHA1.hexdigest([Time.now.to_f, rand, self, args].join)
        end
      end
    end
  end
end
