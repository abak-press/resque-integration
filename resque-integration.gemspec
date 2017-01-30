# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque/integration/version'

Gem::Specification.new do |gem|
  gem.name          = 'resque-integration'
  gem.version       = Resque::Integration::VERSION
  gem.authors       = ['Alexei Mikhailov', 'Michail Merkushin']
  gem.email         = %w(amikhailov83@gmail.com merkushin.m.s@gmail.com)
  gem.summary       = %q{Seamless integration of resque with resque-progress and resque-lock}
  gem.homepage      = 'https://github.com/abak-press/resque-integration'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w(lib)

  gem.metadata['allowed_push_host'] = 'https://gems.railsc.ru'

  gem.add_runtime_dependency 'resque', '= 1.25.2'
  gem.add_runtime_dependency 'railties', '>= 3.0.0'
  gem.add_runtime_dependency 'activerecord', '>= 3.0.0'
  gem.add_runtime_dependency 'actionpack', '>= 3.0.0'
  gem.add_runtime_dependency 'resque-lock', '~> 1.1.0'
  gem.add_runtime_dependency 'resque-meta', '>= 2.0.0'
  gem.add_runtime_dependency 'resque-progress', '~> 1.0.1'
  gem.add_runtime_dependency 'resque-multi-job-forks', '~> 0.4.2'
  gem.add_runtime_dependency 'resque-failed-job-mailer', '~> 0.0.3'
  gem.add_runtime_dependency 'resque-scheduler', '~> 4.0'
  gem.add_runtime_dependency 'resque-retry', '~> 1.5'
  gem.add_runtime_dependency 'god', '~> 0.13.4'

  gem.add_runtime_dependency 'multi_json'
  gem.add_runtime_dependency 'rake'
  gem.add_runtime_dependency 'sinatra'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'mock_redis'
  gem.add_development_dependency 'timecop'
end
