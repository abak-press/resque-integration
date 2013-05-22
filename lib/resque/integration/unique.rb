# coding: utf-8

require 'digest/sha1'

require 'active_support/core_ext/module/aliasing'

require 'resque/plugins/lock'
require 'resque/plugins/progress'

module Resque
  module Integration
    # Unique job
    #
    # @example
    #   class MyJob
    #     extend Resque::Integration::Unique
    #
    #     # jobs are considered as equal if their first argument is the same
    #     lock_on { |*args| args.first }
    #
    #     def self.execute(image_id)
    #       # do it
    #     end
    #   end
    #
    #   MyJob.enqueue(11)
    module Unique
      SALT = 'f5db195354e682fc3389c086beed4f70'.freeze

      def self.extended(base)
        base.extend(Resque::Plugins::Progress)
        base.extend(Resque::Plugins::Lock)
        base.extend(ClassMethods)
        base.singleton_class.class_eval do
          alias_method_chain :enqueue, :check
        end
      end

      module ClassMethods
        # Returns true because job is unique now
        def unique?
          true
        end

        # Get or set proc returning unique arguments
        def lock_on(&block)
          if block_given?
            @unique = block
          else
            @unique ||= proc { |*args| args }
          end
        end

        # LockID should be independent from MetaID
        # @api private
        def lock(meta_id, *args)
          "lock:#{name}-#{Digest::SHA1.hexdigest(lock_on[*args].to_s)}"
        end

        # Overriding +meta_id+ here so now it generates the same MetaID for Jobs with same args
        # @api private
        def meta_id(*args)
          Digest::SHA1.hexdigest([ secret_token, self, lock_on[*args] ].join)
        end

        # get meta object associated with job
        def meta
          get_meta(@meta_id)
        end

        # default `perform` method override
        def perform(meta_id, *args)
          execute(*args)
        end

        def execute(*)
          raise NotImplementedError, "You should implement `execute' method"
        end

        # When job is failed we should remove lock
        def on_failure_lock(e, *args)
          unlock(*args)
        end

        # Before dequeue check if job is running
        def before_dequeue_lock(*args)
          (meta_id = args.first) &&
          (meta = get_meta(meta_id)) &&
          !meta.working?
        end

        # When job is dequeued we should remove lock
        def after_dequeue_lock(*args)
          unlock(*args) if args.any?
        end

        # Fail metadata if dequeue succeed
        def after_dequeue_meta(*args)
          if (meta_id = args.first) && (meta = get_meta(meta_id))
            meta.fail!
          end
        end

        # Is job already in queue or in process?
        def enqueued?(*args)
          # if lock exists and timeout not exceeded
          if locked?(*args)
            get_meta(meta_id(*args))
          else
            nil
          end
        end

        # Returns true if resque job is in locked state
        def locked?(*args)
          key = lock(nil, *args)
          now = Time.now.to_i

          Resque.redis.exists(key) && now <= Resque.redis.get(key).to_i
        end

        # Dequeue unique job
        def dequeue(*args)
          Resque.dequeue(self, meta_id(*args), *args)
        end

        # Overriding +enqueue+ method here so now it returns existing metadata if job already queued
        def enqueue_with_check(*args) #:nodoc:
          meta = enqueued?(*args) and return meta

          # enqueue job and retrieve its meta
          enqueue_without_check(*args)
        end

        private
        # Remove lock for job with given +args+
        def unlock(*args)
          Resque.redis.del(lock(*args))
        end

        def secret_token
          ::Rails.respond_to?(:application) &&
          ::Rails.application &&
          ::Rails.application.config.secret_token
        end
      end
    end # module Unique
  end # module Integration
end # module Resque