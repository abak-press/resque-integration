# coding: utf-8

require 'yaml'
require 'ostruct'

require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/deep_merge'

module Resque
  module Integration
    class Configuration
      # Failure notifier configuration
      class Notifier < OpenStruct
        def initialize(config)
          super(config || {})
        end

        # Is notifier enabled
        def enabled?
          to.any? && enabled.nil? ? true : enabled
        end

        # Returns true if payload should be included into reports
        def include_payload?
          include_payload.nil? ?
            true :
            include_payload
        end

        # Returns recipients list
        def to
          super || []
        end

        # Returns sender address
        def from
          super || 'no_reply@gmail.com'
        end

        # Returns mailer method
        def mail
          (super || :alert).to_sym
        end

        # Returns mailer class
        def mailer
          super || 'ResqueFailedJobMailer::Mailer'
        end
      end

      # Create configuration from given +paths+
      def initialize(*paths)
        @configuration = {}
        paths.each { |f| load f }
      end

      # Returns Resque redis configuration
      #
      # @return [OpenStruct]
      def redis
        @redis ||= (self['redis'] || {}).symbolize_keys.merge(:thread_safe => true)
      end

      # Returns workers configuration
      #
      # @return [Array<Worker>]
      def workers
        @workers ||= (self[:workers] || {}).map { |k, v| Worker.new(k, v) }
      end

      # Returns failure notifier config
      def failure_notifier
        @notifier ||= Notifier.new(self['failure.notifier'])
      end

      # Returns Resque polling interval
      def interval
        (self['resque.interval'] || 5).to_i
      end

      # Returns Resque verbosity level
      def verbosity
        (self['resque.verbosity'] || 0).to_i
      end

      # Returns path to resque log file
      #
      # @return [Pathname]
      def log_file
        ::Rails.root.join(self['resque.log_file'] || 'log/resque.log')
      end

      # Returns pid directory
      #
      # @return [Pathname]
      def pid_dir
        ::Rails.root.join('tmp', 'pids')
      end

      # Returns environment variables that should be associated with this configuration
      def env
        env = self['env'] || {}

        env[:INTERVAL] ||= interval
        env[:VERBOSE] = '1' if verbosity == 1
        env[:VVERBOSE] = '1' if verbosity == 2
        env[:LANG] = 'en_US.UTF-8'

        env[:RAILS_ENV] = ::Rails.env

        Hash[env.map { |k, v| [k, v.to_s] }]
      end

      private
      def load(path)
        if File.exists?(path)
          config = YAML.load(File.read(path))

          @configuration.merge!(config)
        end
      end

      # get value from configuration
      def [](path)
        parts = path.to_s.split('.')
        result = @configuration

        parts.each do |k|
          result = result[k]

          break if result.nil?
        end

        result
      end
    end # class Configuration
  end # module Integration
end # module Resque