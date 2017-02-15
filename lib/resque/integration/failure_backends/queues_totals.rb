module Resque
  module Integration
    module FailureBackends
      class QueuesTotals < ::Resque::Failure::Base
        REDIS_COUNTER_KEY = 'resque:integration:failure_backends:queues_totals'.freeze
        MAX_COUNTER_VALUE = 10_000_000

        private_constant :REDIS_COUNTER_KEY

        def save
          current_value = Resque.redis.hincrby(REDIS_COUNTER_KEY, queue, 1)
          Resque.redis.hset(REDIS_COUNTER_KEY, queue, 1) if current_value >= MAX_COUNTER_VALUE
        end

        def self.queues
          Resque.redis.hkeys(REDIS_COUNTER_KEY)
        end

        def self.count(queue = nil, _class_name = nil)
          if queue.nil?
            Resque.redis.hvals(REDIS_COUNTER_KEY).map(&:to_i).sum
          else
            Resque.redis.hget(REDIS_COUNTER_KEY, queue).to_i
          end
        end

        def self.clear(queue = nil)
          if queue.nil?
            Resque.redis.del(REDIS_COUNTER_KEY)
          else
            Resque.redis.hdel(REDIS_COUNTER_KEY, queue)
          end
        end
      end
    end
  end
end
