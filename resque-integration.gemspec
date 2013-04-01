# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque/integration/version'

Gem::Specification.new do |gem|
  gem.name          = 'resque-integration'
  gem.version       = Resque::Integration::VERSION
  gem.authors       = ['Alexei Mikhailov']
  gem.email         = %w(amikhailov83@gmail.com)
  gem.summary       = %q{Seamless integration of resque with resque-progress and resque-lock}
  gem.homepage      = 'https://github.com/abak-press/resque-integration'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w(lib)

  gem.add_runtime_dependency 'resque', '>= 1.23.0'
  gem.add_runtime_dependency 'railties', '>= 3.0.0'
  gem.add_runtime_dependency 'resque-rails', '>= 1.0.1'
  gem.add_runtime_dependency 'resque-ensure-connected', '>= 0.2.0' # reconnect after fork
  gem.add_runtime_dependency 'resque-lock', '~> 1.1.0'
  gem.add_runtime_dependency 'resque-meta', '>= 2.0.0'
  gem.add_runtime_dependency 'resque-progress', '~> 1.0.1'
  gem.add_runtime_dependency 'resque-multi-job-forks', '~> 0.3.4'

  gem.add_runtime_dependency 'multi_json'
  gem.add_runtime_dependency 'rake'
  gem.add_runtime_dependency 'sinatra'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'mock_redis'
end