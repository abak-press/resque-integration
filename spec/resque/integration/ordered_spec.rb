require "spec_helper"

describe Resque::Integration::Ordered do
  class TestJob
    include Resque::Integration

    unique { |company_id, param1| [company_id] }
    ordered max_iterations: 2
  end

  it "push args to separate queue" do
    meta = TestJob.enqueue(1, 10)
    TestJob.enqueue(1, 20)

    args_key = TestJob.ordered_queue_key(meta.meta_id)
    expect(TestJob).to be_enqueued(1)
    expect(TestJob.ordered_queue_size(meta.meta_id)).to eq 2
  end

  it "execute jobs by each args" do
    meta = TestJob.enqueue(1, 10)
    TestJob.enqueue(1, 20)

    expect(TestJob).to receive(:execute).with(1, 10).ordered
    expect(TestJob).to receive(:execute).with(1, 20).ordered

    TestJob.perform(meta.meta_id)
  end

  it "reenqueue job after max iterations reached" do
    meta = TestJob.enqueue(1, 10)
    TestJob.enqueue(1, 20)
    TestJob.enqueue(1, 30)

    expect(TestJob).to receive(:execute).with(1, 10).ordered
    expect(TestJob).to receive(:execute).with(1, 20).ordered
    expect(TestJob).to_not receive(:execute).with(1, 30).ordered

    TestJob.perform(meta.meta_id)
  end
end
