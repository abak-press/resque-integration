# coding: utf-8

namespace :resque do
  namespace :supervisor do
    desc 'Starts supervisor process'
    task :start => :environment do
      Resque::Integration::Supervisor.start
    end

    desc 'Stop supervisor process'
    task :stop => :environment do
      Resque::Integration::Supervisor.stop
    end

    desc 'Restart supervisor process'
    task :restart => [:stop, :start]
  end
end