module Resque
  module Integration
    module Extensions
      module Worker
        extend ActiveSupport::Concern

        included do
          alias_method_chain :queues, :shuffle
        end

        def queues_with_shuffle
          queues = queues_without_shuffle
          shuffle? ? queues.shuffle : queues
        end

        def shuffle?
          return @shuffle if defined?(@shuffle)
          @shuffle = ENV.key?('SHUFFLE')
        end
      end
    end
  end
end
