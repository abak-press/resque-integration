module Resque
  module Integration
    module Extensions
      # Public: extension for proper determine queue
      # when destroy job with priority
      module Job
        def destroy(queue, klass, *args)
          if klass.respond_to?(:priority?) && klass.priority?
            queue = klass.priority_queue(args.last)
          end

          super
        end
      end
    end
  end
end
