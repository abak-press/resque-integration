# coding: utf-8

require "rails/engine"

module Resque::Integration
  # Rails engine
  # @see http://guides.rubyonrails.org/engines.html
  class Engine < Rails::Engine
    rake_tasks do
      load "resque/integration/tasks/resque.rake"
      load "resque/integration/tasks/supervisor.rake"
    end

    initializer 'resque-integration.config' do
      paths = Rails.root.join('config', 'resque.yml'),
              Rails.root.join('config', 'resque.local.yml')

      Resque.config = Resque::Integration::Configuration.new(*paths.map(&:to_s))
    end

    initializer 'resque-multi-job-forks.hook' do
      # Support for resque-multi-job-forks
      if ENV['JOBS_PER_FORK'] || ENV['MINUTES_PER_FORK']
        Resque.after_fork { ActiveRecord::Base.connection.reconnect! }
      end
    end
  end
end