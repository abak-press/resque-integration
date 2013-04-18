# coding: utf-8

namespace :resque do
  namespace :supervisor do
    desc 'Starts supervisor process (no-op)'
    task :start

    desc 'Stop supervisor process (no-op)'
    task :stop

    desc 'Restart supervisor process (no-op)'
    task :restart
  end
end