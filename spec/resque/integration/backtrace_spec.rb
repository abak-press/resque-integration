# coding: utf-8

require 'spec_helper'
require 'stringio'

describe Resque::Integration::Backtrace do
  class TestError < StandardError; end

  class TestJob
    extend Resque::Integration::Backtrace

    @queue = :jobs

    def self.perform(*)
      raise TestError, 'FooBar'
    end
  end

  context 'redefined logger' do
    let!(:log) { StringIO.new }

    before do
      @origin_logger = Resque.logger
      Resque.logger = MonoLogger.new(log)
    end

    after do
      Resque.logger = @origin_logger
    end

    context 'should reraise error and produce output' do
      it do
        worker = Resque::Worker.new(:jobs)
        job = Resque::Job.new(:jobs, 'class' => TestJob, 'args' => '')
        worker.perform(job)
        expect(Resque::Failure.all['exception']).to eq 'TestError'
        expect(Resque::Failure.all['error']).to eq 'FooBar'
        expect(log.string).to match(/TestError.*FooBar/)
      end
    end
  end
end
