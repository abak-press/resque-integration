# coding: utf-8

require 'yaml'
require 'ostruct'
require 'erb'

require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/deep_merge'

module Resque
  module Integration
    class Configuration
      # Worker entity
      class Worker < OpenStruct
        def initialize(queue, config)
          data = {:queue => queue}

          if config.is_a?(Hash)
            data.merge!(config.symbolize_keys)
          else
            data[:count] = config
          end

          super(data)
        end

        # Returns workers count for given queue
        def count
          [super || 1, 1].max
        end

        # Returns hash of ENV variables that should be associated with this worker
        def env
          env = super || {}

          env[:QUEUE] ||= queue
          env[:JOBS_PER_FORK] ||= jobs_per_fork if jobs_per_fork
          env[:MINUTES_PER_FORK] ||= minutes_per_fork if minutes_per_fork
          env[:SHUFFLE] ||= 1 if shuffle

          Hash[env.map { |k, v| [k, v.to_s] }]
        end
      end

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
        @redis ||= (self['redis'] || {}).symbolize_keys
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

      # Returns flag for cleaning on shutdown see https://github.com/resque/resque/issues/1167
      def run_at_exit_hooks?
        value = self['resque.run_at_exit_hooks']

        if value.is_a?(String) && %w(n no false off disabled).include?(value)
          value = false
        end

        value.nil? ? true : value
      end

      # Returns Resque polling interval
      def interval
        (self['resque.interval'] || 5).to_i
      end

      # Returns Resque verbosity level
      def verbosity
        (self['resque.verbosity'] || 0).to_i
      end

      # Returns Resque log level
      def log_level
        (self['resque.log_level'] || 1).to_i
      end

      # Returns path to resque log file
      def log_file
        self['resque.log_file'] || ::Rails.root.join('log/resque.log').to_s
      end

      def config_file
        self['resque.config_file'] || ::Rails.root.join('config/resque.god').to_s
      end

      def pid_file
        "#{pids}/resque-god.pid"
      end

      def pids
        self['resque.pids'] || ::Rails.root.join('tmp/pids').to_s
      end

      def root
        self['resque.root'] || ::Rails.root.to_s
      end

      # Путь до файла с расписание resque schedule
      #
      # Returns String
      def schedule_file
        self['resque.schedule_file'] || ::Rails.root.join('config', 'resque_schedule.yml')
      end

      # Есть ли расписание у приложения?
      #
      # Returns boolean
      def schedule_exists?
        return @schedule_exists if defined?(@schedule_exists)
        @schedule_exists = File.exist?(schedule_file)
      end

      # Используется ли resque scheduler
      #
      # Returns boolean
      def resque_scheduler?
        value = self['resque.scheduler'] || true

        if value.is_a?(String) && %w(n no false off disabled).include?(value)
          value = false
        end

        value
      end

      # Returns maximum terminate timeout
      def terminate_timeout
        workers.map(&:stop_timeout).compact.max.to_i + 10
      end

      # Returns environment variables that should be associated with this configuration
      def env
        env = self['env'] || {}

        env[:INTERVAL] ||= interval

        Hash[env.map { |k, v| [k, v.to_s] }]
      end

      # Generate GOD configuration file
      def to_god
        template = ERB.new(File.read(File.join(File.dirname(__FILE__), 'god.erb')))
        template.result(binding)
      end

      def god_log_file
        self['resque.god_log_file'] || ::Rails.root.join('log/god.log').to_s
      end

      def god_log_level
        self['resque.god_log_level'] || 'info'
      end

      private
      def load(path)
        if File.exists?(path)
          input = File.read(path)
          input = ERB.new(input).result if defined?(ERB)
          config = YAML.load(input)

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
