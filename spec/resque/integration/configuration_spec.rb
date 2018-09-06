# coding: utf-8

require 'spec_helper'

describe Resque::Integration::Configuration do
  let(:config) do
    File.stub(:exists? => true)
    File.stub(:read)
    ERB.stub_chain(:new, :result)
    YAML.stub(:load => config_yaml)
    described_class.new('path/to/config.yml')
  end

  let(:config_yaml) { {} }

  describe '#schedule_file' do
    let(:config_yaml) { {'resque' => {'schedule_file' => 'schedule.yml'}} }

    it { expect(config.schedule_file).to eq 'schedule.yml' }
  end

  describe '#log_level' do
    context 'when default' do
      it { expect(config.log_level).to eq 1 }
    end

    context 'when defined' do
      let(:config_yaml) { {'resque' => {'log_level' => 2}} }

      it { expect(config.log_level).to eq 2 }
    end
  end

  describe '#resque_scheduler?' do
    context 'when default' do
      it { expect(config.resque_scheduler?).to be_truthy }
    end

    context 'when defined' do
      let(:config_yaml) { {'resque' => {'scheduler' => 'no'}} }

      it { expect(config.resque_scheduler?).to be_falsey }
    end
  end

  describe '#run_at_exit_hooks?' do
    context 'when default' do
      it { expect(config.resque_scheduler?).to be_truthy }
    end

    context 'when defined' do
      let(:config_yaml) { {'resque' => {'run_at_exit_hooks' => 'no'}} }

      it { expect(config.run_at_exit_hooks?).to be_falsey }
    end
  end

  describe '#temporary_exceptions' do
    context 'when default' do
      it { expect(config.temporary_exceptions).to eq({}) }
    end

    context 'when defined' do
      let(:config_yaml) { {'resque' => {'temporary_exceptions' => {'StandardError' => 12}}} }

      it { expect(config.temporary_exceptions).to eq(StandardError => 12) }
    end
  end
end

describe Resque::Integration::Configuration::Notifier do
  context 'when NilClass given as config' do
    subject(:config) { described_class::new(nil) }

    it { should_not be_enabled }
    its(:include_payload?) { should be_truthy }
    its(:to) { should be_empty }
    its(:from) { should eq 'no_reply@gmail.com' }
    its(:mail) { should eq :alert }
    its(:mailer) { should eq 'ResqueFailedJobMailer::Mailer' }
  end

  context 'when Hash given as config' do
    let :configuration do
      {to: ['to1@mail', 'to2@mail'],
       from: 'from@mail',
       enabled: false,
       include_payload: false,
       mail: 'notify',
       mailer: 'MyMailer'}
    end

    subject(:config) { described_class::new(configuration) }

    it { should_not be_enabled }
    its(:include_payload?) { should be_falsey }
    its(:to) { should include 'to1@mail' }
    its(:to) { should include 'to2@mail' }
    its(:from) { should eq 'from@mail' }
    its(:mail) { should eq :notify }
    its(:mailer) { should eq 'MyMailer' }
  end
end

describe Resque::Integration::Configuration::Worker do
  describe '.new' do
    context 'when Integer given as config' do
      subject(:config) { described_class::new(:default, 2) }

      its(:queue) { should eq :default }
      its(:count) { should eq 2 }
    end

    context 'when Hash given as config' do
      subject(:config) { described_class::new(:default, :count => 2) }

      its(:queue) { should eq :default }
      its(:count) { should eq 2 }
    end
  end

  describe '#count' do
    context 'when initialized without count paramter' do
      subject { described_class::new(:default, {}) }

      its(:count) { should eq 1 }
    end

    context 'when initialized with count <= 0' do
      subject { described_class::new(:default, :count => 0) }

      its(:count) { should eq 1 }
    end
  end

  describe '#env' do
    let :config do
      described_class.new(:default,
                           :count => 2,
                           :jobs_per_fork => 10,
                           :minutes_per_fork => 5,
                           :shuffle => true,
                           :env => {:VAR => 2})
    end

    subject { config.env }

    its([:QUEUE]) { should eq 'default' }
    its([:JOBS_PER_FORK]) { should eq '10' }
    its([:MINUTES_PER_FORK]) { should eq '5' }
    its([:SHUFFLE]) { should eq '1' }
    its([:VAR]) { should eq '2' }

    context "when shuffle is disabled" do
      let(:config) { described_class.new(:default, shuffle: false) }
      its([:SHUFFLE]) { should be_nil }
    end
  end
end
