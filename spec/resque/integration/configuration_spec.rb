# coding: utf-8

require 'spec_helper'

describe Resque::Integration::Configuration::Notifier do
  context 'when NilClass given as config' do
    subject(:config) { described_class::new(nil) }

    it { should_not be_enabled }
    its(:include_payload?) { should be_true }
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
    its(:include_payload?) { should be_false }
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
      described_class::new(:default,
                           :count => 2,
                           :jobs_per_fork => 10,
                           :minutes_per_fork => 5,
                           :env => {:VAR => 2})
    end
    subject { config.env }

    its([:QUEUE]) { should eq 'default' }
    its([:JOBS_PER_FORK]) { should eq '10' }
    its([:MINUTES_PER_FORK]) { should eq '5' }
    its([:VAR]) { should eq '2' }
  end
end