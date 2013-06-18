# coding: utf-8

require 'digest/md5'

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
      save_md5
    end
  end

  desc 'Restart Resque workers'
  task :restart => :conf do
    if god_stopped?
      Rake::Task['resque:start'].invoke
    elsif config_changed?
      puts 'Resque config changed, God should be stopped and started again.'

      # it can take long, we'll run it in background
      puts 'Stopping god. It can take a while...'

      Process.daemon(true, false)

      # Stop everything
      Rake::Task['resque:terminate'].invoke

      # Start again
      Rake::Task['resque:start'].invoke
    else
      puts 'Restarting god. Executing in background. It can take a while...'

      Process.daemon(true, false)

      `#{god} restart resque`
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

  # Returns true if config file was changed since last deploy
  def config_changed?
    config_md5 != current_md5
  end

  def current_md5
    Resque.redis.get('config:md5')
  end

  def save_md5
    Resque.redis.set('config:md5', config_md5)
  end

  def config_md5
    Digest::MD5.hexdigest(File.read(config_file))
  end
end