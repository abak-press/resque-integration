# coding: utf-8
require "rubygems"
require "bundler"

Bundler.setup

require "resque/integration/application"

run Resque::Integration::Application