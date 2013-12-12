# coding: utf-8

namespace :resque do
  desc 'Generate God configuration file'
  task :conf => :environment do
    File.write(config_file, Resque.config.to_god)

    puts "God configuration file generated to #{config_file}"
  end

  desc 'Start God server and watch for Resque workers'
  task :start => :conf do
    if god_running?
      puts `#{god} start resque`
    else
      puts `#{god} -c #{config_file} -P #{pid_file} -l #{log_file}`
    end
  end

  desc 'Restart Resque workers'
  task :restart => :conf do
    if god_stopped?
      Rake::Task['resque:start'].invoke
    else
      puts `#{god} load #{config_file} stop && #{god} restart resque`
    end
  end

  desc 'Stop Resque workers'
  task :stop do
    puts `#{god} stop resque`
  end

  desc 'Stop Resque workers and quit God'
  task :terminate do
    puts `#{god} terminate`
  end

  desc 'Stop processing any new jobs'
  task :pause do
    puts `#{god} signal resque USR2`
  end

  desc 'Resume jobs processing after pause'
  task :resume do
    puts `#{god} signal resque CONT`
  end

  desc 'Shows Resque status'
  task :status do
    puts `#{god} status resque`
  end

  private
  def god
    `which god`.strip
  end

  def god_running?
    File.exists?(pid_file) && Process.kill(0, File.read(pid_file).to_i)
  rescue Errno::ESRCH
    false
  rescue Errno::EPERM
    true
  end

  def god_stopped?
    !god_running?
  end

  def pid_file
    Rails.root.join('tmp/pids/resque-god.pid').to_s
  end

  def log_file
    Rails.root.join(Resque.config.log_file).to_s
  end

  def config_file
    Rails.root.join('config/resque.god').to_s
  end
end