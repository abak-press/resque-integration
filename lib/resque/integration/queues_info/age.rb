module Resque
  module Integration
    class QueuesInfo
      class Age
        def initialize(config)
          @config = config
        end

        def time(queue)
          from_time = Time.now.utc
          max_secs = 0

          jobs.each do |job|
            next unless job['queue'] == queue
            job_secs = seconds_for(job, from_time)
            max_secs = job_secs if job_secs > max_secs
          end

          max_secs
        end

        def overall
          from_time = Time.now.utc

          max_secs = 0

          jobs.each do |job|
            next unless job['queue']
            job_secs = seconds_for(job, from_time)
            next if job_secs < threshold(job['queue'])
            max_secs = job_secs if job_secs > max_secs
          end

          max_secs
        end

        def threshold(queue)
          @config.max_age(queue)
        end

        private

        def jobs
          Resque.workers.each_with_object([]) { |worker, memo| memo << worker.job unless worker.idle? }
        end

        def seconds_for(job, from_time)
          (from_time - DateTime.strptime(job['run_at'], '%Y-%m-%dT%H:%M:%S').utc).to_i
        end
      end
    end
  end
end
