class RetriesStandardErrorJob
  include Resque::Integration

  retries temporary: true, exceptions: [StandardError]
  queue :test_retries

  def self.execute
    DummyForRetriesService.call
  end
end
