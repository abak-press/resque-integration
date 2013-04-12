# coding: utf-8

require 'ostruct'
require 'resque/integration/process'

module Resque
  module Integration
    # Структура, представляющая собой воркера
    class Worker
      PID_PREFIX = 'resque_work_'.freeze
      PID_SUFFIX = '.pid'.freeze

      class << self
        # Returns ID for each next worker
        def next_id
          @id ||= 0
          @id  += 1
        end

        # Returns path to directory with pid files
        def pid_dir
          ::Rails.root.join('tmp', 'pids')
        end
      end

      attr_reader :id, :config, :process
      delegate :alive?, :pid, :to => :process
      delegate :queue, :to => :config

      def initialize(queue, config)
        @id = Worker.next_id
        data = {:queue => queue}

        if config.is_a?(Hash)
          data.merge!(config.symbolize_keys)
        else
          data[:count] = config
        end
        @config = OpenStruct.new(data)
        @process = Resque::Integration::Process.new(pid_file)
      end

      # Returns workers count for given queue
      def count
        [@config.count || 1, 1].max
      end

      # Returns true if worker is dead
      def dead?
        !alive?
      end

      # Starts a worker and detaches from spawned process
      def start
        Resque.logger.info("Spawning worker ##{id} (queue=#{config.queue})...")

        process.spawn(
            env,
            "bundle exec rake resque:work >> #{Resque.config.log_file.to_s} 2>&1",
            :chdir => ::Rails.root.to_s
        )
        process.detach
      end

      # Gracefully stops a worker by sending him SIGQUIT
      def stop
        if alive?
          Resque.logger.info("Stopping worker ##{id} (pid=#{process.pid}, queue=#{config.queue})...")

          process.send('QUIT') and process.wait
        end
      end

      # Returns worker env variables
      def env
        env = Resque.config.env.merge(config.env || {})

        env[:PIDFILE] = pid_file.to_s
        env[:QUEUE] ||= config.queue
        env[:JOBS_PER_FORK] ||= config.jobs_per_fork if config.jobs_per_fork
        env[:MINUTES_PER_FORK] ||= config.minutes_per_fork if config.minutes_per_fork

        Hash[env.map { |k, v| [k.to_s, v.to_s] }]
      end

      private
      # Returns path to worker's pid-file
      def pid_file
        Resque.config.pid_dir.join([PID_PREFIX, id, PID_SUFFIX].join)
      end
    end # class Worker
  end # module Integration
end # module Resque