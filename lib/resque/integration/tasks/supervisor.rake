# coding: utf-8

namespace :resque do
  namespace :supervisor do
    desc 'Starts supervisor process (no-op now)'
    task :start => :environment do
      deprecate('start')
    end

    desc 'Stop supervisor process (no-op now)'
    task :stop => :environment do
      deprecate('stop')
    end

    desc 'Restart supervisor process (no-op now)'
    task :restart do
      deprecate('restart')
    end
    
    private
    def deprecate(task)
      warn "resque:supervisor:#{task} tasks are deprecated. Use resque:#{task} instead."
    end
  end
end