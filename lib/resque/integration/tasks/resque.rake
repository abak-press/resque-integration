# coding: utf-8

namespace :resque do
  desc 'Generate God configuration file'
  task :conf => :environment do
    File.write(Resque.config.config_file, Resque.config.to_god)

    puts "God configuration file generated to #{Resque.config.config_file}"
  end

  desc 'Start God server and watch for Resque workers'
  task :start => :conf do
    if god_running?
      puts `#{god} start resque`
    else
      puts `#{god} -c #{Resque.config.config_file} -P #{Resque.config.pid_file} --log #{Resque.config.god_log_file} --log-level #{Resque.config.god_log_level} --no-syslog`
    end
  end

  desc 'Restart Resque workers'
  task :restart => :conf do
    if god_stopped?
      Rake::Task['resque:start'].invoke
    else
      puts `#{god} load #{Resque.config.config_file} stop && #{god} restart resque`
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

  namespace :logs do
    desc 'Rotate resque logs'
    task :rotate => :environment do
      if god_running?
        Process.kill('USR1', File.read(Resque.config.pid_file).to_i)
        sleep 3
        puts `#{god} signal resque HUP`
      else
        puts 'god is not running'
      end
    end
  end

  private

  def god
    `which god`.strip
  end

  def god_running?
    File.exists?(Resque.config.pid_file) && Process.kill(0, File.read(Resque.config.pid_file).to_i)
  rescue Errno::ESRCH
    false
  rescue Errno::EPERM
    true
  end

  def god_stopped?
    !god_running?
  end
end
