# coding: utf-8

require 'spec_helper'

describe Resque::Integration, '#unique?' do
  let(:job) { Class.new }
  before { job.send :include, Resque::Integration }

  subject { job }

  context 'when #unique is not called' do
    it { should_not be_unique }
  end

  context 'when #unique is called' do
    before { job.unique }

    it { should be_unique }
  end
end