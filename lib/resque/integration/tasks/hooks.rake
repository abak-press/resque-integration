# coding: utf-8
require 'erb'

namespace :resque do
  # Здесь мы добавляем некоторые необходимые для корректной работы "хуки".
  #
  # @see https://github.com/resque/resque/tree/1-x-stable#workers
  task :setup => :environment do
    # принудительно инициализируем приложение
    # (rails 3 не делают этого при запуске из rake-задачи)
    Rails.application.eager_load! if Rails::VERSION::MAJOR < 4

    # Включаем логирование в resque
    ENV['VERBOSE'] = '1'

    # перенаправление вывода в файл
    Resque::Integration::LogsRotator.redirect_std
    # слушать HUP сигнал для ротации логов
    Resque::Integration::LogsRotator.register_hup_signal

    # Нужно закрыть все соединения в **родительском** процессе,
    # Нужно также закрыть соединение к memcache
    Resque.before_first_fork do
      ActiveRecord::Base.connection_handler.clear_all_connections!
      Rails.cache.reset if Rails.cache.respond_to?(:reset)
    end

    Resque.before_fork do
      client = if Gem::Version.new(::Redis::VERSION) < Gem::Version.new('4')
                 Resque.redis.client
               else
                 Resque.redis._client
               end
      client.disconnect

      ActiveRecord::Base.connection_handler.clear_all_connections!
    end

    Resque.after_fork do |job|
      $0 = "resque-#{Resque::Version}: Processing #{job.queue}/#{job.payload['class']} since #{Time.now.to_s(:db)}"

      ActiveRecord::Base.establish_connection

      client = if Gem::Version.new(::Redis::VERSION) < Gem::Version.new('4')
                 Resque.redis.client
               else
                 Resque.redis._client
               end
      client.connect
    end

    # Support for resque-multi-job-forks
    require 'resque-multi-job-forks' if ENV['JOBS_PER_FORK'] || ENV['MINUTES_PER_FORK']

    if Resque.config.run_at_exit_hooks? && ENV['RUN_AT_EXIT_HOOKS'].nil?
      ENV['RUN_AT_EXIT_HOOKS'] = '1'
    end
  end
end
