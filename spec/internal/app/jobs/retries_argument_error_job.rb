class RetriesArgumentErrorJob
  include Resque::Integration

  retries temporary: true, exceptions: [ArgumentError]
  queue :test_retries

  def self.execute
    DummyForRetriesService.call
  end
end
