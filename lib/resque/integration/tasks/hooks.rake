# coding: utf-8

namespace :resque do
  # Здесь мы добавляем некоторые необходимые для корректной работы "хуки".
  #
  # @see https://github.com/resque/resque/tree/1-x-stable#workers
  task :setup => :environment do
    # Reestablish Redis connection for each fork
    # Tested on both redis-2.2.x and redis-3.0.x
    #
    # @see https://groups.google.com/forum/#!msg/ror2ru/CV96h5OGDxY/IqZbRsl-BcIJ
    Resque.before_fork { Resque.redis.client.disconnect }
    Resque.after_fork { Resque.redis.client.connect }

    # Нужно закрыть все соединения в **родительском** процессе,
    # все остальное делает гем `resque-ensure-connected`.
    #
    # Вообще, он делает буквально следующее:
    #   Resque.after_fork { ActiveRecord::Base.connection_handler.verify_active_connections! }
    #
    # Это работает
    Resque.before_first_fork { ActiveRecord::Base.connection_handler.clear_all_connections! }

    # Нужно также закрыть соединение к memcache
    Resque.before_first_fork { Rails.cache.reset if Rails.cache.respond_to?(:reset) }

    # Support for resque-multi-job-forks
    if ENV['JOBS_PER_FORK'] || ENV['MINUTES_PER_FORK']
      require 'resque-multi-job-forks'
    end
  end
end