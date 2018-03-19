require 'bundler/setup'
require 'pry-byebug'
require 'rspec'
require 'rspec/its'
require 'resque'
require 'simplecov'
require 'mock_redis'
require 'timecop'
require 'pry-byebug'
require 'combustion'

Resque.redis = MockRedis.new

SimpleCov.start

require 'resque/integration'

Combustion.initialize! :action_controller
Dir["./spec/shared/**/*.rb"].each(&method(:require))

RSpec.configure do |config|
  config.before do
    Resque.redis.redis.flushdb
  end

  config.filter_run_including focus: true
  config.run_all_when_everything_filtered = true
end
