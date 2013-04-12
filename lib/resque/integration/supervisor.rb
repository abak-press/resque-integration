# coding: utf-8

require 'resque'
require 'resque/integration/process'

module Resque
  module Integration
    class Supervisor
      # С каким интервалом опрашивать воркеров
      INTERVAL = 15

      class << self
        delegate :start, :stop, :to => :new
      end

      def initialize
        @process = Resque::Integration::Process.new(pid_file)
      end

      # Start Supervisor main loop in separate process
      def start
        @process.fork do
          Resque.logger.info("Supervisor started (pid=#{::Process.pid})")

          $0 = 'Resque: supervisor'
          main_loop

          Resque.logger.info("Supervisor stopped (pid=#{::Process.pid})")
        end

        @process.detach
      end

      # Stop Supervisor main loop
      def stop
        Resque.logger.info('Sending SIGQUIT to supervisor process...')

        @process.send('QUIT')
        @process.wait
      end

      private
      def main_loop
        catch(:stop) do
          trap('QUIT') { throw :stop }
          trap('TERM') { throw :stop }

          loop do
            reap and sleep INTERVAL
          end
        end
      end

      def reap
        prune_dead_workers
        restart_dead_processes
      end

      def restart_dead_processes
        Resque.logger.debug('Restarting dead processes...')

        Resque.config.workers.select(&:dead?).each do |worker|
          Resque.logger.warn("Found dead worker (pid=#{worker.pid}, restarting...")

          worker.start

          Resque.logger.info("New worker spawned (pid=#{worker.pid})")
        end
      end # def restart_dead_processes

      def prune_dead_workers
        Resque.logger.debug('Pruning dead workers from Redis...')

        Resque.workers.each do |worker|
          begin
            worker.prune_dead_workers
          rescue => ex
            log_exception(ex, 'Cannot prune resque workers')
          end
        end
      end # def prune_dead_workers

      def log_exception(exception, prefix = nil)
        Resque.logger.fatal { "%s %s (%s)\n%s" % [
            prefix ? "#{prefix}:" : '',
            exception.message,
            exception.class.to_s,
            exception.backtrace.join("\n")
        ] }
      end # def log_exception

      def pid_file
        Resque.config.pid_dir.join('resque-watchdog.pid')
      end
    end # class Reaper
  end # module Integration
end # module Resque