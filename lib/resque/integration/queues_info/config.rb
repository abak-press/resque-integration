require 'yaml'

module Resque
  module Integration
    class QueuesInfo
      class Config
        def initialize(config_path)
          config = load_config(config_path)
          @defaults = config['defaults']
          @queues = expand_config(config['queues'])
        end

        def max_age(queue)
          threshold(queue, 'max_age')
        end

        def max_size(queue)
          threshold(queue, 'max_size')
        end

        def max_failures_count(queue, period)
          threshold(queue, "max_failures_count_per_#{period}")
        end

        def channel(queue)
          channel = @queues[queue].try(:[], 'channel') || @defaults['channel']
          Array.wrap(channel).join(' ')
        end

        def data
          @data ||= @queues.map do |queue_name, _queue_params|
            {
              '{#QUEUE}' => queue_name,
              '{#THRESHOLD_AGE}' => max_age(queue_name),
              '{#THRESHOLD_SIZE}' => max_size(queue_name),
              '{#THRESHOLD_FAILURES_PER_5M}' => max_failures_count(queue_name, '5m'),
              '{#THRESHOLD_FAILURES_PER_1H}' => max_failures_count(queue_name, '1h'),
              '{#CHANNEL}' => channel(queue_name)
            }
          end
        end

        private

        def threshold(queue, param)
          @queues[queue].try(:[], param) || @defaults[param]
        end

        def load_config(path)
          input = File.read(path)
          input = ERB.new(input).result if defined?(ERB)
          YAML.load(input)
        end

        def expand_config(config)
          expanded_config = {}

          config.keys.each do |key|
            key.split(',').each do |queue|
              queue.chomp!
              queue.strip!

              (expanded_config[queue] ||= {}).merge!(config[key])
            end
          end

          expanded_config
        end
      end
    end
  end
end
