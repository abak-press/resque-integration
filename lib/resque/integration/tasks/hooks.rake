# coding: utf-8

namespace :resque do
  # Здесь мы добавляем некоторые необходимые для корректной работы "хуки".
  #
  # @see https://github.com/resque/resque/tree/1-x-stable#workers
  task :setup => :environment do
    # принудительно инициализируем приложение
    # (rails 3 не делают этого при запуске из rake-задачи)
    Rails.application.eager_load! if Rails::VERSION::MAJOR < 4

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
      Resque.redis.client.disconnect

      ActiveRecord::Base.connection_handler.clear_all_connections!
    end

    Resque.after_fork do |job|
      $0 = "resque-#{Resque::Version}: Processing #{job.queue}/#{job.payload['class']} since #{Time.now.to_s(:db)}"

      ActiveRecord::Base.establish_connection

      Resque.redis.client.connect
    end

    # Support for resque-multi-job-forks
    require 'resque-multi-job-forks' if ENV['JOBS_PER_FORK'] || ENV['MINUTES_PER_FORK']

    if Resque.config.resque_scheduler? && Resque.config.schedule_exists?
      Resque.schedule = YAML.load_file(Resque.config.schedule_file)
    end

    if Resque.config.run_at_exit_hooks? && ENV['RUN_AT_EXIT_HOOKS'].nil?
      ENV['RUN_AT_EXIT_HOOKS'] = '1'
    end
  end
end
