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

        def channel(queue)
          Array.wrap((@queues[queue] || @defaults)['channel']).join(' ')
        end

        def data
          @data ||= @queues.map do |k, v|
            {
              "{#QUEUE}" => k
            }
          end
        end

        private

        def threshold(queue, param)
          (@queues[queue] || @defaults)[param]
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
              queue.chomp!
              queue.strip!
              config[queue] = v
            end
          end

          config
        end
      end
    end
  end
end
