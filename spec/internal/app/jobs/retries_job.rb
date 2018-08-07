class RetriesJob
  include Resque::Integration

  retries
  queue :test_retries

  def self.execute
    DummyForRetriesService.call
  end
end
