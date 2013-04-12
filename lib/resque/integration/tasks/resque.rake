# coding: utf-8

namespace :resque do
  desc 'Start resque workers configured in resque.yml'
  task :start => :environment do
    Resque::Integration::CLI.start
    Resque::Integration::Supervisor.start
  end

  desc 'Stop resque workers'
  task :stop => :environment do
    Resque::Integration::Supervisor.stop
    Resque::Integration::CLI.stop
  end

  desc 'Restart resque workers'
  task :restart => :environment do
    Resque::Integration::Supervisor.stop
    Resque::Integration::CLI.restart
    Resque::Integration::Supervisor.start
  end
end