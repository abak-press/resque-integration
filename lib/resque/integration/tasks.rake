# coding: utf-8

namespace :resque do
  namespace :supervisor do
    desc 'Starts supervisor process'
    task :start => :environment do
      puts `#{supervisor_path} -h #{Resque.redis.client.host} \\
                          -p #{Resque.redis.client.port} \\
                          -i #{pid_file} \\
                          -l #{log_file} \\
                          --db=#{Resque.redis.client.db} \\
                          -n #{Resque.redis.namespace} \\
                          -d \\
                          start`
    end

    desc 'Stop supervisor process'
    task :stop => :environment do
      puts `#{supervisor_path} -i #{pid_file} -l #{log_file} stop`
    end

    desc 'Restart supervisor process'
    task :restart => [:stop, :start]

    def supervisor_path
      Gem.bin_path('resque-integration', 'resque-supervisor')
    end

    def pid_file
      Rails.root.join('tmp', 'pids', 'resque-supervisor.pid').to_s
    end

    def log_file
      Rails.root.join('log', 'resque-supervisor.log').to_s
    end
  end
end