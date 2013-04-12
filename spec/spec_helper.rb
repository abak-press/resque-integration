# coding: utf-8
require 'bundler/setup'
require 'rspec'
require 'resque'
require 'simplecov'
require 'mock_redis'
require 'combustion'

SimpleCov.start 'test_frameworks'

require 'resque/integration'
Combustion.initialize!

Resque.redis = MockRedis.new