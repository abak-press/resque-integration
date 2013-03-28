require 'rails'

# Supply generator for Rails 3.0.x or if asset pipeline is not enabled
if !defined?(Sprockets) || !::Rails.application.config.assets.enabled
  module Resque::Integration
    module Generators
      class InstallGenerator < ::Rails::Generators::Base

        desc "This generator installs resque-integration (#{Resque::Integration::VERSION}) assets"
        source_root File.expand_path('../../../../../../vendor/assets', __FILE__)

        def copy_resque_progressbar
          say_status("copying", "resque-integration (#{Resque::Integration::VERSION})", :green)
          copy_file "images/progressbar/white.gif", "public/images/progressbar/white.gif"
          copy_file "javascripts/jquery.progressbar.js", "public/javascripts/jquery.js"
          copy_file "stylesheets/jquery.progressbar.no_pipeline.css", "public/stylesheets/jquery.progressbar.css"
        end
      end
    end
  end
else
  module Resque::Integration
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        desc "Just show instructions so people will know what to do when mistakenly using generator for Rails 3.1 apps"

        def do_nothing
          say_status("deprecated", "You are using Rails 3.1 with the asset pipeline enabled, so this generator is not needed.")
          say_status("", "The necessary files are already in your asset pipeline.")
          say_status("", "Just add `//= require jquery.progressbar` to your app/assets/javascripts/application.js")
          say_status("", "If you upgraded your app from Rails 3.0 and still have jquery.progressbar.js in your javascripts, be sure to remove them.")
          say_status("", "If you do not want the asset pipeline enabled, you may turn it off in application.rb and re-run this generator.")
          # ok, nothing
        end
      end
    end
  end
end