if RUBY_VERSION < '2.4'
  appraise 'rails4.0' do
    gem 'rails', '~> 4.0.13'
  end
end

appraise 'rails4.2' do
  gem 'rails', '~> 4.2.9'
end

appraise 'rails5.0' do
  gem 'rails', '~> 5.0.0'
end

appraise 'rails5.1' do
  gem 'rails', '~> 5.1.0'
end

appraise 'rails5.2' do
  gem 'rails', '~> 5.2.0', '< 5.2.4.1'
  gem 'mimemagic', '<= 0.3.9' if RUBY_VERSION < '2.3'
end
