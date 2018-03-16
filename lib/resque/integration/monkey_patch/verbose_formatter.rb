require "resque/log_formatters/verbose_formatter"

module Resque
  class VerboseFormatter
    def call(serverity, datetime, progname, msg)
      time = Time.now.strftime('%H:%M:%S %Y-%m-%d')
      "** [#{time}] #$$: #{msg}\n"
    end
  end
end
