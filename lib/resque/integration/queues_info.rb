module Resque
  module Integration
    class QueuesInfo
      def initialize(options)
        config = load_config(options.fetch(:config))
        @defaults = config['defaults']
        @queues = expand_config(config['queues'])
      end

      def age_for_queue(queue)
        job, max_time = find_longest_job { |job| job['queue'] == queue }

        return 0 if job.nil? || max_time.nil?

        max_time
      end

      def age_overall
        job, max_time = find_longest_job { |job| !job['queue'].nil? }

        return 0 if job.nil? || max_time.nil?

        threshold = (@queues[job['queue']] || @defaults)['max_age']

        max_time >= threshold ? max_time : 0
      end

      def size_for_queue(queue = nil)
        Resque.size(queue) || 0
      end

      def size_overall
        queue, size = Resque.queues.map do |queue|
          [queue, Resque.size(queue).to_i]
        end.max_by(&:last)

        thresholds = (@queues[queue] || @defaults)['max_size']

        size >= thresholds ? size : 0
      end

      def data
        @data ||= @queues.map do |k, v|
          {
            "{#QUEUE}" => k,
            "{#THRESHOLD_AGE}" => v.fetch('max_age'),
            "{#THRESHOLD_SIZE}" => v.fetch('max_size')
          }
        end
      end

      private

      def find_longest_job
        workers = Resque.workers
        jobs = workers.map(&:job)

        working_jobs = workers.zip(jobs).select do |w, j|
          !w.idle? && yield(j)
        end

        working_jobs.map do |_, job|
          [job, seconds_for(job)]
        end.max_by(&:last)
      end

      def seconds_for(job)
        (Time.now.utc - DateTime.strptime(job['run_at'], '%Y-%m-%dT%H:%M:%S').utc).to_i
      end

      def load_config(path)
        input = File.read(path)
        input = ERB.new(input).result if defined?(ERB)
        YAML.load(input)
      end

      def expand_config(config)
        keys = config.keys.dup

        keys.each do |key|
          v = config.delete(key)

          key.split(',').each do |queue|
            config[queue] = v
          end
        end

        config
      end
    end
  end
end
