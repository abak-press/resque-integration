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

describe Resque::Integration::Configuration do
  let(:config) { described_class::new(Rails.root.join('config', 'resque.yml')) }

  describe '#workers' do
    subject { config.workers }

    it { should have(2).items }
    its('first.queue') { should eq 'default' }
    its('second.queue') { should eq 'images' }
  end
end