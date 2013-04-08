# coding: utf-8

require 'rails/engine'
require 'active_support/core_ext/string/inflections'

module Resque::Integration
  # Rails engine
  # @see http://guides.rubyonrails.org/engines.html
  class Engine < Rails::Engine
    rake_tasks do
      load 'resque/integration/tasks/resque.rake'
      load 'resque/integration/tasks/supervisor.rake'
    end

    initializer 'resque-integration.config' do
      paths = Rails.root.join('config', 'resque.yml'),
              Rails.root.join('config', 'resque.local.yml')

      Resque.config = Resque::Integration::Configuration.new(*paths.map(&:to_s))
    end

    initializer 'resque-integration.redis' do
      redis = Resque.config.redis

      Resque.redis = [redis.host, redis.port, redis.db].join(':')
      Resque.redis.namespace = redis.namespace

      # Reconnect on each fork
      Resque.after_fork { Resque.redis.client.reconnect }
    end

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

    initializer 'resque-multi-job-forks.hook' do
      # Support for resque-multi-job-forks
      if ENV['JOBS_PER_FORK'] || ENV['MINUTES_PER_FORK']
        Resque.after_fork { ActiveRecord::Base.connection.reconnect! }
      end
    end
  end
end