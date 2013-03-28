# coding: utf-8
require "resque/integration"
require "resque/plugins/meta"
require "sinatra/base"
require "multi_json"

module Resque::Integration
  # Rack-приложение (построенное на Sinatra)
  # Бэкэнд для progress-bar'а
  # Умеет лишь одно - отдавать данные о задаче в JSON-формате
  class Application < Sinatra::Base
    JOB_ID_PATTERN = %r{([a-f0-9]{32})}

    set(:environment) { ENV['RAILS_ENV'] || ENV['RACK_ENV'] || :development }
    set(:raise_errors) { !production? }
    set(:show_exceptions) { development? }

    before do
      content_type :json
    end

    configure :production, :development do
      enable :logging
    end

    # main handler
    get '/:id' do |id|
      halt 404 unless JOB_ID_PATTERN =~ id

      # find job first
      meta = Resque::Plugins::Meta.get_meta(id)

      # no job - no job
      halt 404 unless meta

      # build job data
      data = {
          :enqueued_at => meta.enqueued_at,
          :started_at  => meta.started_at,
          :finished_at => meta.finished_at,
          :succeeded   => meta.succeeded?,
          :failed      => meta.failed?,
          :progress    => meta.progress,
          :payload     => meta['payload']
      }

      MultiJson.dump(data)
    end

    # do not send pretty 404 page
    not_found { '' }
  end
end