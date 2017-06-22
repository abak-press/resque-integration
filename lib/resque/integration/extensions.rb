module Resque
  module Integration
    module Extensions
      autoload :Worker, "resque/integration/extensions/worker"
      autoload :Job, "resque/integration/extensions/job"
    end
  end
end
