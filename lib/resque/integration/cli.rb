# coding: utf-8

require 'optparse'
require 'active_support/core_ext/hash/keys'

module Resque
  module Integration
    class CLI
      class Configuration
        attr_accessor :workers, :interval, :environment, :verbosity

        def initialize
          self.workers = {'*' => 1}
          self.interval = 5
          self.environment = 'development'
        end
      end # class Configuration

      attr_reader :root, :config, :command, :background

      # @param [Pathname] root
      def initialize(root)
        @root = root
        @config = Configuration.new
        @background = true
        @option_parser = OptionParser.new do |opts|
          opts.banner = 'Usage: script/resque [options] COMMAND WORKERS'
          opts.separator ''
          opts.separator 'Example: script/resque start queue1 4 queue2 2 * 8'
          opts.separator ''

          opts.on('-e', '--environment [ENV]', 'Rails app environment') do |env|
            @config.environment = env
          end

          opts.on('-i', '--inteval [INTERVAL]', 'Polling interval') do |i|
            @config.interval = i.to_i
          end

          opts.on('-v', '--[no-]verbose', 'Add verbosity to output') do |v|
            @config.verbosity = v
          end

          opts.on('-d', '--[no-]daemon', 'Run in background') do |v|
            @background = v
          end

          opts.on('-h', '--help', 'Show this message') do
            puts opts
            exit(1)
          end
        end
      end

      # run application
      def run
        parse_arguments

        if %w(start stop restart).include?(command)
          puts "#{command} workers..."

          # run any command in daemon mode
          Process.daemon if @background

          send(command)
        end
      end

      # Stops workers
      def stop
        Pathname.glob(pid_dir.join('resque_work_*.pid')).each do |file|
          stop_worker(file)
        end
      end

      # Starts workers
      def start
        /_(\d+)\.pid\z/ === Dir[pid_dir.join('resque_work_*.pid').to_s].sort.last || ''
        # увеличивать номер воркера после каждого деплоя
        worker_id = ($1 || 0).to_i + 1

        config.workers.each do |queue, number|
          number.times do
            start_worker(queue, worker_id)

            worker_id += 1
          end
        end
      end

      def restart
        stop
        start
      end

      private
      def parse_arguments
        @option_parser.parse!(ARGV)
        # first argument is a command
        @command = ARGV.shift

        unless ARGV.empty?
          config.workers = {}

          ARGV.each_slice(2) do |queue, workers|
            config.workers[queue] = (workers || 1).to_i
          end
        end
      end

      def start_worker(queue, worker_id)
        pid_file = pid_dir.join("resque_work_#{worker_id}.pid")

        environ = {
            RAILS_ENV: config.environment,
            QUEUE: queue,
            INTERVAL: config.interval.to_s,
            PIDFILE: pid_file.to_s,
            LANG: 'en_US.UTF-8'
        }
        environ[:VERBOSE] = '1' if config.verbosity
        environ.stringify_keys!

        pid = Process.spawn(
            environ,
            "nohup bundle exec rake resque:work >> #{log_file.to_s} 2>&1 ",
            :chdir => root.to_s
        )
        Process.detach(pid)

        #puts "Queue #{queue}: Worker ##{worker_id} started (pid=#{pid})"
      end

      def stop_worker(pid_file)
        pid = pid_file.read

        begin
          Process.kill('QUIT', pid.to_i)

          # wait for worker to die
          Process.daemon

          $0 = "Resque: waiting for process ##{pid} to die"
          sleep 1 while process_alive?(pid)
        rescue Errno::ESRCH
          # ignore
        ensure
          File.delete(pid_file)
        end
      end

      def pid_dir
        root.join('tmp', 'pids')
      end

      def log_file
        root.join('log', 'resque.log')
      end

      def process_alive?(pid)
        Process.kill(0, pid.to_i)
        true
      rescue Errno::ESRCH
        false
      end
    end # class CLI
  end # module Integration
end # module Resque