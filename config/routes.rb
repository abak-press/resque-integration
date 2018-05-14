Rails.application.routes.draw do
  namespace :resque do
    namespace :queues do
      resource :info, only: :show, controller: :info
      resource :status, only: :show, controller: :status
    end
  end

  get "#{Rails.application.config.resque_job_status.fetch(:route_path)}(/:id)",
      to: 'resque/jobs#show',
      as: 'job_status',
      constraints: ::Rails.application.config.resque_job_status.fetch(:route_constraints)
end
