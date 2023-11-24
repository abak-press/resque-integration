require 'digest/sha1'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/hash'
require 'resque/plugins/progress'

module Resque
  module Integration
    # Unique job
    #
    # @example
    #   class MyJob
    #     include Resque::Integration
    #
    #     # jobs are considered as equal if their first argument is the same
    #     unique { |*args| args.first }
    #
    #     def self.execute(image_id)
    #       # do it
    #     end
    #   end
    #
    #   MyJob.enqueue(11)
    module Unique
      LOCK_TIMEOUT = 259_200 # 3 days

      def self.extended(base)
        if base.singleton_class.include?(::Resque::Integration::Priority)
          raise 'Uniqueness should be enabled before Prioritness'
        end

        base.extend(::Resque::Plugins::Progress)
        base.singleton_class.prepend(Overrides)
      end

      module Overrides
        # Overriding +enqueue+ method here so now it returns existing metadata if job already queued
        def enqueue(*args) #:nodoc:
          meta = enqueued?(*args)
          return meta if meta

          # enqueue job and retrieve its meta
          super
        end

        # Overriding +meta_id+ here so now it generates the same MetaID for Jobs with same args
        def meta_id(*args)
          ::Digest::SHA1.hexdigest([secret_token, self, lock_on.call(*args)].join)
        end
      end

      # Returns true because job is unique now
      def unique?
        true
      end

      # Метод вызывает resque-scheduler чтобы поставить задание в текущую очередь
      def scheduled(queue, klass, *args)
        klass.constantize.enqueue_to(queue, *args)
      end

      # Метод вызывает resque-retry когда ставить отложенное задание
      # здесь мы убираем meta_id из аргументов
      def retry_args(meta_id, *args)
        args
      end

      # Метод вызывает resque-retry, когда записывает/читает число перезапусков
      #  - во время работы воркера первым аргументом передается meta_id;
      #  - во время чтения из вебинтерфейса, meta_id не передается, т.к. она выкидывается во время перепостановки
      #  джоба(см retry_args);
      #  - если метод вызывается в пользовательском коде(и @meta_id отсутствует), то meta_id нельзя передавать.
      def retry_identifier(*args)
        return if args.empty?
        args.shift if @meta_id.is_a?(String) && !@meta_id.empty? && @meta_id == args.first
        lock_id(*args)
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
      def lock_id(*args)
        args = args.map { |i| i.is_a?(Hash) ? i.with_indifferent_access : i }
        locked_args = lock_on.call(*args)
        encoded_args = ::Digest::SHA1.hexdigest(obj_to_string(locked_args))
        "lock:#{name}-#{encoded_args}"
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
      def on_failure_lock(_e, _meta_id, *args)
        unlock(*args)
      end

      # Before dequeue check if job is running
      def before_dequeue_lock(*args)
        (meta_id = args.first) &&
        (meta = get_meta(meta_id)) &&
        !meta.working?
      end

      def on_failure_retry(exception, *args)
        return unless defined?(super)

        # Keep meta_id if kill -9 (or ABRT)
        @meta_id = args.first if exception.is_a?(::Resque::DirtyExit)

        super
      end

      # Before enqueue acquire a lock
      #
      # Returns boolean
      def before_enqueue_lock(_meta_id, *args)
        ::Resque.redis.set(lock_id(*args), 1, ex: lock_timeout, nx: true)
      end

      def around_perform_lock(_meta_id, *args)
        yield
      ensure
        # Always clear the lock when we're done, even if there is an error.
        unlock(*args)
      end

      # When job is dequeued we should remove lock
      def after_dequeue_lock(_meta_id, *args)
        unlock(*args)
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
        get_meta(meta_id(*args)) if locked?(*args)
      end

      def lock_timeout
        LOCK_TIMEOUT
      end

      # Returns true if resque job is in locked state
      def locked?(*args)
        ::Resque.redis.exists?(lock_id(*args))
      end

      # Dequeue unique job
      def dequeue(*args)
        ::Resque.dequeue(self, meta_id(*args), *args)
      end

      def enqueue_to(queue, *args)
        meta = enqueued?(*args)
        return meta if meta.present?

        meta = ::Resque::Plugins::Meta::Metadata.new('meta_id' => meta_id(args), 'job_class' => to_s)
        meta.save

        ::Resque.enqueue_to(queue, self, meta.meta_id, *args)
        meta
      end

      private

      # Remove lock for job with given +args+
      def unlock(*args)
        ::Resque.redis.del(lock_id(*args))
      end

      def secret_token
        ::Rails.respond_to?(:application) &&
        ::Rails.application &&
        ::Rails.application.config.secret_token
      end

      def obj_to_string(obj)
        case obj
        when Hash
          s = []
          obj.keys.sort.each do |k|
            s << obj_to_string(k)
            s << obj_to_string(obj[k])
          end
          s.to_s
        when Array
          obj.map { |a| obj_to_string(a) }.to_s
        else
          obj.to_s
        end
      end
    end # module Unique
  end # module Integration
end # module Resque
