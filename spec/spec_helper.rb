require 'bundler/setup'
require 'pry-byebug'
require 'rspec'
require 'rspec/its'
require 'resque'
require 'simplecov'
require 'timecop'
require 'pry-byebug'
require 'combustion'

redis = Redis.new(host: ENV['TEST_REDIS_HOST'])
Redis.current = redis
Resque.redis = redis

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
