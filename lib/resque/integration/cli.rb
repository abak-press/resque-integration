# coding: utf-8

require 'optparse'
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
        Pathname.glob(pid_dir.join('resque_work_*.pid')).each do |file|
          stop_worker(file)
        end
      end

      # Starts workers
      def start
        /_(\d+)\.pid\z/ === Dir[pid_dir.join('resque_work_*.pid').to_s].sort.last || ''
        # увеличивать номер воркера после каждого деплоя
        worker_id = ($1 || 0).to_i + 1

        Resque.config.workers.each do |worker|
          worker.count.times do
            start_worker(worker, worker_id)

            worker_id += 1
          end
        end
      end

      def restart
        stop
        start
      end

      private
      def start_worker(worker, worker_id)
        pid_file = pid_dir.join("resque_work_#{worker_id}.pid")

        environ = {
            RAILS_ENV: ::Rails.env,
            PIDFILE: pid_file.to_s,
            LANG: 'en_US.UTF-8'
        }.merge(Resque.config.env).
          merge(worker.env)

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
        root.join(Resque.config.log_file || 'log/resque.log')
      end

      def root
        ::Rails.root
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