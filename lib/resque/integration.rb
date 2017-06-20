# coding: utf-8
require 'resque/integration/version'

require 'resque'

require 'active_support/core_ext/kernel/reporting'

silence_warnings { require 'resque/plugins/meta' }

require 'rails/railtie'
require 'rake'

require 'active_record'
require 'action_pack'

require 'active_support/concern'

require 'resque/integration/hooks'

require 'resque/scheduler'
require 'resque/scheduler/tasks'

require 'resque-retry'

require 'active_support/core_ext/module/attribute_accessors'

module Resque
  include Integration::Hooks
  extend Integration::Hooks

  # Resque.config is available now
  mattr_accessor :config

  def queues_info
    return @queues_info if defined?(@queues_info)

    queues_info_config = Rails.root.join('config', 'resque_queues.yml')

    @queues_info = Resque::Integration::QueuesInfo.new(config: queues_info_config)
  end

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
    autoload :Continuous, 'resque/integration/continuous'
    autoload :Unique, 'resque/integration/unique'
    autoload :Ordered, 'resque/integration/ordered'
    autoload :LogsRotator, 'resque/integration/logs_rotator'
    autoload :QueuesInfo, 'resque/integration/queues_info'
    autoload :Extensions, 'resque/integration/extensions'
    autoload :FailureBackends, 'resque/integration/failure_backends'
    autoload :Priority, 'resque/integration/priority'

    extend ActiveSupport::Concern

    included do
      extend Backtrace

      @queue ||= :default
    end

    module ClassMethods
      # Get or set queue name (just a synonym to resque native methodology)
      def queue(name = nil)
        if name
          @queue = name
        else
          @queue
        end
      end

      # Mark Job as unique and set given +callback+ or +block+ as Unique Arguments procedure
      def unique(callback = nil, &block)
        extend Unique

        lock_on(&(callback || block))
      end

      # Extend job with 'continuous' functionality so you can re-enqueue job with +continue+ method.
      def continuous
        extend Continuous
      end

      def unique?
        false
      end

      # extend resque-retry
      #
      # options - Hash
      #           :limit - Integer (default: 2)
      #           :delay - Integer (default: 60)
      #
      # Returns nothing
      def retrys(options = {})
        if unique?
          raise '`retrys` should be declared higher in code than `unique`'
        end

        extend Resque::Plugins::Retry

        @retry_limit = options.fetch(:limit, 2)
        @retry_delay = options.fetch(:delay, 60)
      end

      # Mark Job as ordered
      def ordered(options = {})
        unique unless unique?
        continuous
        extend Ordered

        self.max_iterations = options.fetch(:max_iterations, 20)
        self.uniqueness = Ordered::Uniqueness.new(&options[:unique]) if options.key?(:unique)
      end
    end
  end # module Integration
end # module Resque

require 'resque/integration/engine'
