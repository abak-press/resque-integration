# coding: utf-8

module Resque
  module Integration
    # Extend your job with this class to see full backtrace in resque log
    module Backtrace
      def around_perform_backtrace(*)
        yield
      rescue => ex
        message = "%s: %s\n%s" % [ex.class.name, ex.message, ex.backtrace.join("\n")]
        $stderr.puts(message)

        raise
      end
    end # module Backtrace
  end # module Integration
end # module Resque