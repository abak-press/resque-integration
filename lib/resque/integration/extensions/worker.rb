module Resque
  module Integration
    module Extensions
      module Worker
        def queues
          queues = super
          shuffle? ? queues.shuffle : queues
        end

        def shuffle?
          return @shuffle if defined?(@shuffle)
          @shuffle = !ENV['SHUFFLE'].to_s.empty?
        end
      end
    end
  end
end
