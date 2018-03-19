require 'spec_helper'

describe Resque::Integration::Unique, '#meta_id, #lock' do
  let(:job) { Class.new }
  before { job.extend Resque::Integration::Unique }

  context 'when unique arguments are not set' do
    it 'returns same results when equal arguments given' do
      job.meta_id('a', 'b').should eq job.meta_id('a', 'b')
      job.lock_id('a', 'b').should eq job.lock_id('a', 'b')
    end

    it 'returns different results when different arguments given' do
      job.meta_id('a', 'b').should_not eq job.meta_id('a', 'c')
      job.lock_id('a', 'b').should_not eq job.lock_id('a', 'c')
    end
  end

  context 'when unique arguments are set' do
    # mark second argument as unique
    before { job.lock_on &->(a, b) { b } }

    it 'returns same results when equal arguments given' do
      job.meta_id('a', 'b').should eq job.meta_id('a', 'b')
      job.lock_id('a', 'b').should eq job.lock_id('a', 'b')
      job.lock_id('a', foo: 1).should eq job.lock_id('a', foo: 1)

      job.meta_id('a', 'b').should eq job.meta_id('c', 'b')
      job.lock_id('a', 'b').should eq job.lock_id('c', 'b')
      job.lock_id('a', foo: 1).should eq job.lock_id('c', foo: 1)
    end

    it 'returns different results when different arguments given' do
      job.meta_id('a', 'b').should_not eq job.meta_id('a', 'c')
      job.lock_id('a', 'b').should_not eq job.lock_id('a', 'c')
    end
  end
end

describe Resque::Integration::Unique, '#enqueue, #enqueued?' do
  class JobEnqueueTest
    extend Resque::Integration::Unique

    @queue = :queue1
  end

  it 'returns false when job is not enqueued' do
    JobEnqueueTest.should_not be_enqueued(0)
  end

  it 'returns new meta when job is enqueued' do
    meta = JobEnqueueTest.enqueue(1)
    meta.should be_a Resque::Plugins::Meta::Metadata

    JobEnqueueTest.should be_enqueued(1)
  end

  it 'returns new meta when job is enqueued to specific queue' do
    meta = JobEnqueueTest.enqueue_to(:fast, 1)
    meta.should be_a Resque::Plugins::Meta::Metadata

    expect(JobEnqueueTest.enqueued?(1)).to_not be_nil
    expect(Resque.size(:fast)).to eq 1
  end

  it 'returns new meta when job is scheduled' do
    meta = JobEnqueueTest.scheduled(:fast, 'JobEnqueueTest', 1)
    meta.should be_a Resque::Plugins::Meta::Metadata

    expect(JobEnqueueTest.enqueued?(1)).to_not be_nil
    expect(Resque.size(:fast)).to eq 1
  end

  it 'returns the same meta if job already in queue' do
    meta1 = JobEnqueueTest.enqueue(2)
    meta2 = JobEnqueueTest.enqueue(2)

    meta1.meta_id.should eq meta2.meta_id
    meta1.enqueued_at.should eq meta2.enqueued_at

    JobEnqueueTest.should be_enqueued(2)
  end
end

describe Resque::Integration::Unique, '#dequeue' do
  class JobDequeueTest
    extend Resque::Integration::Unique

    @queue = :queue2

    def self.execute(x)
      sleep 0.1
    end
  end

  it 'dequeues and unlocks job if job is not in work now' do
    JobDequeueTest.enqueue(1)
    JobDequeueTest.should be_enqueued(1)

    JobDequeueTest.dequeue(1)
    JobDequeueTest.should_not be_enqueued(1)
    JobDequeueTest.should_not be_locked(1)

    meta = JobDequeueTest.get_meta(JobDequeueTest.meta_id(1))
    meta.should be_failed
  end

  it 'does not dequeue jobs in progress' do
    meta = JobDequeueTest.enqueue(1)

    job = Resque.reserve(:queue2)

    worker = Thread.new {
      job.perform
    }

    sleep 0.01 # give a worker some time to start
    meta.reload!
    meta.should be_working

    JobDequeueTest.dequeue(1)
    JobDequeueTest.should be_locked(1)
    JobDequeueTest.should be_enqueued(1)

    worker.join
  end
end

describe Resque::Integration::Unique, '#on_failure_retry' do
  class JobUniqueWithRetry
    include Resque::Integration
    extend Resque::Plugins::Retry

    @retry_limit = 2
    @retry_delay = 1
    @retry_exceptions = [IOError]

    unique do |foo_var, params|
      params[:foo]
    end

    queue :default

    def self.execute(foo_var, params)
      sleep 0.2
      Resque.logger.info 'Hello, world'
    end
  end

  class JobOnlyUnique
    include Resque::Integration

    unique

    def self.execute
      raise ArgumentError.new('Some exception in Job')
    end
  end

  let(:worker) { Resque::Worker.new(:default) }

  context 'when unique with retry' do
    let(:job) { Resque::Job.new(:default, 'class' => 'JobUniqueWithRetry', 'args' => ['abcd', 1, {foo: 'bar'}]) }

    before { worker.working_on(job) }

    it do
      expect { worker.unregister_worker }.not_to raise_error

      expect(Resque::Failure.count).to eq 1
      expect(Resque::Failure.all['exception']).to eq 'Resque::DirtyExit'
    end
  end

  context 'when only unique' do
    let(:job) { Resque::Job.new(:default, 'class' => 'JobOnlyUnique', 'args' => ['abcd']) }

    it do
      expect { job.perform }.not_to raise_error(RuntimeError, /no superclass method `on_failure_retry'/)
      expect { job.perform }.to raise_error(ArgumentError)
    end
  end
end
