# coding: utf-8

require 'redis'
require 'redis/version'
require 'rails/engine'
require 'active_support/core_ext/string/inflections'

module Resque::Integration
  # Rails engine
  # @see http://guides.rubyonrails.org/engines.html
  class Engine < Rails::Engine
    rake_tasks do
      load 'resque/integration/tasks/hooks.rake'
      load 'resque/integration/tasks/resque.rake'
      load 'resque/integration/tasks/supervisor.rake' # deprecated
    end

    # Читает конфиг-файлы config/resque.yml и config/resque.local.yml,
    # мерджит результаты и сохраняет в Resque.config
    initializer 'resque-integration.config' do
      paths = Rails.root.join('config', 'resque.yml'),
              Rails.root.join('config', 'resque.local.yml')

      Resque.config = Resque::Integration::Configuration.new(*paths.map(&:to_s))
    end

    # Устанавливает для Resque соединение с Редисом,
    # данные берутся из конфига (см. выше)
    initializer 'resque-integration.redis' do
      redis = Resque.config.redis

      Resque.redis = Redis.new(redis)
      Resque.redis.namespace = redis[:namespace] if redis[:namespace]
    end

    # Конфигурирование плагина resque-failed-job-mailer.
    # Данные берутся из конфига (см. выше)
    initializer 'resque-integration.failure_notifier' do
      notifier = Resque.config.failure_notifier

      if notifier.enabled?
        require 'resque_failed_job_mailer'

        Resque::Failure::Notifier.configure do |config|
          config.to = notifier.to
          config.from = notifier.from
          config.include_payload = notifier.include_payload?
          config.mail = notifier.mail
          config.mailer = notifier.mailer.constantize
        end
      end
    end
  end # class Engine
end # module Resque::Integration