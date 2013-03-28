# coding: utf-8

require 'forwardable'

module Resque
  module Integration
    class Supervisor
      INTERVAL = 30

      class << self
        extend Forwardable

        def_delegators :new, :start, :stop
      end

      # Start supervisor process
      def start
        $stderr.puts 'Supervisor already running...' and return if running?

        # daemonize self
        Process.daemon(true, true)

        register_signal_handlers

        # write pid to file
        File.write(pid_file.to_s, Process.pid)

        loop do
          Resque.workers.each(&:prune_dead_workers)
          sleep(INTERVAL)
        end
      rescue
        stop
      end

      # Stop supervisor process
      def stop
        if running?
          Process.kill('QUIT', pid)
        end
        pid_file.delete if pid_file.exist?
      end

      private
      def pid_file
        ::Rails.root.join('tmp', 'pids', 'resque-supervisor.pid')
      end

      def running?
        pid_file.exist? && Process.kill(0, pid)
      rescue Errno::ESRCH
        false
      end

      def pid
        pid_file.read.strip.to_i
      end

      def register_signal_handlers
        trap('QUIT') { stop; exit }
        trap('TERM') { stop; exit }
      end
    end # class Supervisor
  end # module Integration
end # module Resque