# coding: utf-8

require 'spec_helper'

require 'resque/integration/process'
require 'tempfile'

describe Resque::Integration::Process do
  let(:pid_file) { Tempfile.new('resque-integration').path }
  let(:process) { described_class::new(pid_file) }

  describe '#pid' do
    it 'returns false when file does not exist' do
      File.delete(pid_file)

      process.pid.should be_false
    end

    it 'returns false when file exists but empty' do
      File.truncate(pid_file, 0)

      process.pid.should be_false
    end

    it 'return Integer when file contains number' do
      File.write(pid_file, '21000')

      process.pid.should eq 21000
    end
  end

  describe '#alive?' do
    it 'returns false when #pid returns false' do
      process.stub(:pid => false)
      process.should_not be_alive
    end

    it 'returns false when #pid returns Integer but process it not running' do
      process.stub(:pid => 127000)
      process.should_not be_alive
    end

    it 'returns true when #pid returns Integer and process is running' do
      pid = fork { sleep 1; exit! }
      Process.detach(pid)

      process.stub(:pid => pid)
      process.should be_alive
    end

    it 'returns true when #pid returns Integer, process is running but sending signals is not permitted' do
      process.stub(:pid => 1)
      process.should be_alive
    end
  end

  describe '#send' do
    it 'does not send any signals when pid returns false' do
      process.stub(:pid => false)
      Process.should_not_receive(:kill)

      process.send(0)
    end

    it 'send signal to existing process' do
      pid = fork { sleep 1; exit! }
      Process.detach(pid)

      process.stub(:pid => pid)

      Process.should_receive(:kill).with('KILL', pid).and_call_original
      process.send('KILL')
    end

    it 'returns false when process not found' do
      process.stub(:pid => 217000)
      process.send('KILL').should be_false
    end
  end

  describe '#spawn' do
    it 'writes process pid to pid-file' do
      pid = process.spawn('sleep 1')
      File.read(pid_file).should eq pid.to_s

      process.should be_alive
      Process.detach(pid)
    end
  end

  describe '#fork' do
    it 'forks current process' do
      pid = process.fork { sleep 1; exit! }
      File.read(pid_file).should eq pid.to_s

      process.should be_alive
      Process.detach(pid)
    end
  end

  describe '#wait' do
    it 'waits until process dies' do
      process.spawn('sleep 0.1')

      Process.should_receive(:wait).and_call_original
      process.wait

      process.should_not be_alive
    end
  end

  describe '#detach' do
    it 'detaches from spawned process' do
      process.spawn('sleep 1')

      Process.should_receive(:detach).and_call_original
      process.detach

      process.should be_alive
    end
  end
end