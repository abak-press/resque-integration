# coding: utf-8
require 'bundler/setup'
require 'rspec'
require 'resque'
require 'simplecov'
require 'mock_redis'

Resque.redis = MockRedis.new

SimpleCov.start

require 'resque/integration'