require 'resque/integration/unique'

namespace :resque do
  namespace :lock do
    task expire_all: :environment do
      puts "Start expiring all resque locks"

      redis = ::Resque.redis
      cursor = 0
      batch_size = 10_000
      timeout = ::Resque::Integration::Unique::LOCK_TIMEOUT
      count = 0
      pattern = "lock:*"

      loop do
        cursor, keys = redis.scan(cursor, count: batch_size, match: pattern)
        cursor = cursor.to_i

        unless keys.empty?
          redis.pipelined do
            keys.each do |key|
              redis.expire(key, timeout)
            end
          end

          count += keys.size
          puts "Expired #{count}..."
        end

        break if cursor.zero?
      end

      puts "Expired total #{count} keys."
      puts "Done."
    end
  end
end
