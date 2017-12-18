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
#   class UniqueTestJob
#     include Resque::Integration
#
#     unique { |company_id, param1| [company_id] }
#     ordered max_iterations: 10, unique: ->(_company_id, param1) { [param1] }
#     ...
#   end
#
module Resque
  module Integration
    module Ordered
      ARGS_EXPIRATION = 1.week

      def self.extended(base)
        unless base.singleton_class.include?(::Resque::Integration::Unique)
          base.extend ::Resque::Integration::Unique
        end

        unless base.singleton_class.include?(::Resque::Integration::Continuous)
          base.extend ::Resque::Integration::Continuous
        end

        base.singleton_class.class_eval do
          attr_accessor :max_iterations, :uniqueness

          prepend Overrides
        end
      end

      class Uniqueness
        def initialize(&block)
          @unique_block = block
        end

        def key(meta_id)
          "ordered:unique:#{meta_id}"
        end

        def remove(meta_id, args)
          Resque.redis.hdel(key(meta_id), encoded_unique_args(args))
        end

        def size(meta_id)
          Resque.redis.hlen(key(meta_id)).to_i
        end

        def encoded_unique_args(args)
          Resque.encode(@unique_block.call(*args))
        end

        def ordered_meta_id(meta_id, args)
          Resque.redis.hget(key(meta_id), encoded_unique_args(args))
        end

        def set(meta_id, args, ordered_meta_id)
          unique_key = key(meta_id)

          if Resque.redis.hset(unique_key, encoded_unique_args(args), ordered_meta_id)
            Resque.redis.expire(unique_key, ARGS_EXPIRATION)
          end
        end
      end

      module Overrides
        def enqueue(*args)
          meta = super

          if uniqueness && ordered_meta_id = uniqueness.ordered_meta_id(meta.meta_id, args)
            return get_meta(ordered_meta_id)
          end

          ordered_meta = ::Resque::Plugins::Meta::Metadata.new('meta_id' => ordered_meta_id(args), 'job_class' => self)
          ordered_meta.save

          uniqueness.set(meta.meta_id, args, ordered_meta.meta_id) if uniqueness
          args.unshift(ordered_meta.meta_id)
          encoded_args = ::Resque.encode(args)
          args_key = ordered_queue_key(meta.meta_id)

          ::Resque.redis.rpush(args_key, encoded_args)
          ::Resque.redis.expire(args_key, ARGS_EXPIRATION)

          ordered_meta
        end

        def perform(meta_id, *)
          args_key = ordered_queue_key(meta_id)
          i = 1
          while job_args = ::Resque.redis.lpop(args_key)
            job_args = ::Resque.decode(job_args)
            ordered_meta = get_meta(job_args.shift)
            ordered_meta.start!

            begin
              execute(ordered_meta, *job_args)
            rescue Exception
              ordered_meta.fail!
              raise
            ensure
              uniqueness.remove(meta_id, job_args) if uniqueness
            end

            ordered_meta.finish!

            i += 1
            return continue if max_iterations && i > max_iterations && ordered_queue_size(meta_id) > 0
          end
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
