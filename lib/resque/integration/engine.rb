# coding: utf-8

require "rails/engine"

module Resque::Integration
  # Rails engine
  # @see http://guides.rubyonrails.org/engines.html
  class Engine < Rails::Engine
    rake_tasks do
      load "resque/integration/tasks.rake"
    end
  end
end