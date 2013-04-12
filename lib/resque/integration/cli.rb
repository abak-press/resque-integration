# coding: utf-8

require 'forwardable'

require 'active_support/core_ext/hash/keys'

module Resque
  module Integration
    class CLI
      class << self
        extend Forwardable

        def_delegators :new, :start, :stop, :restart
      end

      # Stops workers
      def stop
        background!

        $0 = "Resque: stop processes #{workers.map(&:pid).join(', ')}"

        waiting = workers.map do |worker|
          Thread.start(worker) { |w| w.stop }
        end

        # wait until all workers are dead
        waiting.each(&:join)
      end

      # Starts workers
      def start
        workers.each(&:start)
      end

      # Restart workers in parallel
      def restart
        background!

        waiting = workers.map do |worker|
          Thread.start(worker) do |w|
            w.stop
            w.start
          end
        end

        waiting.each(&:join)
      end

      private
      def workers
        Resque.config.workers
      end

      def background!
        ::Process.daemon(true, true)
      end
    end # class CLI
  end # module Integration
end # module Resque