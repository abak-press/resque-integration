# coding: utf-8

module Resque
  module Integration
    # Extend your job with this class to see full backtrace in resque log
    module Backtrace
      def around_perform_backtrace(*)
        yield
      rescue => ex
        $stderr.puts(_format_exception(ex))

        raise
      end

      private
      def _format_exception(exception)
        bt = exception.backtrace.dup

        "%s %s: %s (%s)\n%s" % [
          Time.now.to_s,
          bt.shift,
          exception.message,
          exception.class.to_s,
          bt.map { |line| ' ' * 4 + line }.join("\n")
        ]
      end
    end # module Backtrace
  end # module Integration
end # module Resque