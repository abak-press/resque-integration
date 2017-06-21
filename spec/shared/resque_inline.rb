RSpec.shared_context 'resque inline' do
  around do |example|
    inline = Resque.inline
    Resque.inline = true

    example.run

    Resque.inline = inline
  end
end
