class DummyForRetriesService
  def self.call
    raise StandardError.new('test')
  end
end
