# coding: utf-8

require 'spec_helper'
require 'resque/integration/worker'

describe Resque::Integration::Worker do
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

  describe '#id' do
    it 'generates unique IDs for workers' do
      w1 = described_class::new(:default, 1)
      w2 = described_class::new(:default, 1)

      w1.id.should_not eq w2.id
    end
  end
end