# coding: utf-8

namespace :resque do
  desc 'Start resque workers configured in resque.yml'
  task :start => :environment do
    daemon.start
  end

  desc 'Stop resque workers'
  task :stop => :environment do
    daemon.stop
  end

  desc 'Restart resque workers'
  task :restart => :environment do
    daemon.restart
  end

  private
  def daemon
    Process.daemon(true, true)

    Resque::Integration::CLI
  end
end