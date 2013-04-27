# coding: utf-8

module Resque
  module Integration
    # Backport of resque-1.24.x hooks
    # @see https://github.com/resque/resque/pull/680/files
    module Hooks
      # We do not want to patch Worker, so we declare callable Array
      class CallableArray < Array
        def call(*args)
          each { |hook| hook.call(*args) }
        end
      end
      # Call with a block to register a hook.
      # Call with no arguments to return all registered hooks.
      def before_first_fork(&block)
        block ? register_hook(:before_first_fork, block) : hooks(:before_first_fork)
      end

      # Register a before_first_fork proc.
      def before_first_fork=(block)
        register_hook(:before_first_fork, block)
      end

      # Call with a block to register a hook.
      # Call with no arguments to return all registered hooks.
      def before_fork(&block)
        block ? register_hook(:before_fork, block) : hooks(:before_fork)
      end

      # Register a before_fork proc.
      def before_fork=(block)
        register_hook(:before_fork, block)
      end

      # Call with a block to register a hook.
      # Call with no arguments to return all registered hooks.
      def after_fork(&block)
        block ? register_hook(:after_fork, block) : hooks(:after_fork)
      end

      # Register an after_fork proc.
      def after_fork=(block)
        register_hook(:after_fork, block)
      end

      private

      # Register a new proc as a hook. If the block is nil this is the
      # equivalent of removing all hooks of the given name.
      #
      # `name` is the hook that the block should be registered with.
      def register_hook(name, block)
        return clear_hooks(name) if block.nil?

        @hooks ||= {}
        @hooks[name] ||= CallableArray.new
        @hooks[name] << block
      end

      # Clear all hooks given a hook name.
      def clear_hooks(name)
        @hooks && @hooks[name] = CallableArray.new
      end

      # Retrieve all hooks of a given name.
      def hooks(name)
        (@hooks && @hooks[name]) || CallableArray.new
      end
    end # module Hooks
  end # module Integration
end # module Resque