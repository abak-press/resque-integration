# coding: utf-8
require "resque/integration/version"

require "resque"

require "rails/railtie"
require "rake"
require "resque-rails"

require "active_record"
require "resque-ensure-connected"

require "resque/plugins/lock"
require "resque/plugins/progress"

require "active_support/concern"

require "resque/integration/engine"
require "resque/integration/backtrace"

require "active_support/core_ext/module/attribute_accessors"

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
  #
  #     lock_on do |*args|
  #       [args.first]
  #     end
  #
  #     def self.execute(*args)
  #     end
  #   end
  module Integration
    autoload :Application, "resque/integration/application"
    autoload :CLI, "resque/integration/cli"
    autoload :Configuration, "resque/integration/configuration"
    autoload :Supervisor, "resque/integration/supervisor"

    extend ActiveSupport::Concern

    included do
      extend Backtrace
      extend Resque::Plugins::Progress
      extend Resque::Plugins::Lock

      @queue ||= :default
      @lock_on ||= proc { |*args| args }

      # LockID is now independent from MetaID
      # @api private
      def self.lock(meta_id, *args) #:nodoc:
        "lock:#{name}-#{@lock_on[*args].to_s}"
      end

      # Overriding +meta_id+ here so now it generates the same MetaID for Jobs with same args
      # @api private
      def self.meta_id(*args) #:nodoc:
        Digest::SHA1.hexdigest([ ::Rails.application.config.secret_token, self, @lock_on[*args] ].join)
      end

      # Overriding +enqueue+ method here so now it returns existing metadata if job already queued
      def self.enqueue(*args) #:nodoc:
        meta = enqueued?(*args) and return meta

        # enqueue job and retrieve its meta
        super
      end
    end

    module ClassMethods
      # Set queue name (just a synonym to resque native methodology)
      def queue(name)
        @queue = name
      end

      # Define a proc for lock key generation
      def lock_on(&block)
        raise ArgumentError, 'Block expected' unless block_given?

        @lock_on = block
      end

      # Is job already in queue or in process?
      def enqueued?(*args)
        key = lock(nil, *args)
        now = Time.now.to_i

        # if lock exists and timeout not exceeded
        if Resque.redis.exists(key) && now <= Resque.redis.get(key).to_i
          get_meta(meta_id(*args))
        else
          nil
        end
      end

      # get meta object associated with job
      def meta
        get_meta(@meta_id)
      end

      def perform(meta_id, *args)
        execute(*args)
      end

      def execute(*)
        raise NotImplementedError, "You should implement `execute' method"
      end

      def on_failure_lock(e, *args)
        Resque.redis.del(lock(*args))
      end
    end
  end # module Integration
end # module Resque
