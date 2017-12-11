module Resque
  module Integration
    # Continuous job can re-enqueue self with respect to resque-lock and resque-meta.
    #
    # @example
    #   class ResqueJob
    #     include Resque::Integration
    #
    #     unique
    #     continuous
    #
    #     def self.execute(id)
    #       chunk = Company.find(id).products.limit(1000)
    #
    #       if chunk.size > 0
    #         heavy_work
    #         continue # it will re-enqueue the job with the same arguments. Avoid infinite loops!
    #       end
    #     end
    #   end
    module Continuous
      # Remove any locks if needed and re-enqueue job with the same arguments
      def continue(*args)
        @continued = args
      end
      private :continue # one should not call it from outside

      # This callback resets Meta's finish flags
      def after_perform_reset_meta(*)
        if should_reset_meta?
          meta_obj = meta

          meta_obj.data.delete('succeeded')
          meta_obj.data.delete('finished_at')

          meta_obj.save
        end
      end

      # Just to ensure that previous jobs won't affect current
      def before_perform_continue(*)
        @continued = nil
      end

      # `after` callbacks are executed after `around` callbacks
      # so here we can re-enqueue the job, because lock (from resque-lock) already released
      def after_perform_continue(*args)
        if continued?
          args = if @continued.any?
            if unique?
              meta_id = args.first # we should keep meta_id as first argument
              [meta_id] + @continued
            else
              @continued
            end
          else
            args
          end

          ::Resque.enqueue(self, *args)
        end
      end

      private

      def continued?
        !@continued.nil?
      end

      def should_reset_meta?
        continued? && unique? && meta
      end
    end # module Continuous
  end # module Integration
end # module Resque
