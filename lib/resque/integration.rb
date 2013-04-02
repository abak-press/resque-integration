# coding: utf-8
require 'resque/integration/version'

require 'resque'

require 'rails/railtie'
require 'rake'
require 'resque-rails'

require 'active_record'
require 'resque-ensure-connected'

require 'active_support/concern'

require 'resque/integration/engine'

require 'active_support/core_ext/module/attribute_accessors'

module Resque
  # Resque.config is available now
  mattr_accessor :config

  # Seamless resque integration with all necessary plugins
  # You should define an +execute+ method (not +perform+)
  #
  # Usage:
  #   class MyJob
  #     include Resque::Integration
  #
  #     queue :my_queue
  #     unique ->(*args) { args.first }

  #     def self.execute(*args)
  #     end
  #   end
  module Integration
    autoload :Application, 'resque/integration/application'
    autoload :Backtrace, 'resque/integration/backtrace'
    autoload :CLI, 'resque/integration/cli'
    autoload :Configuration, 'resque/integration/configuration'
    autoload :Supervisor, 'resque/integration/supervisor'
    autoload :Unique, 'resque/integration/unique'

    extend ActiveSupport::Concern

    included do
      extend Backtrace

      @queue ||= :default
    end

    module ClassMethods
      # Set queue name (just a synonym to resque native methodology)
      def queue(name)
        @queue = name
      end

      # Mark Job as unique and set given +callback+ or +block+ as Unique Arguments procedure
      def unique(callback=nil, &block)
        extend Unique

        lock_on(&(callback || block))
      end

      def unique?
        false
      end
    end
  end # module Integration
end # module Resque