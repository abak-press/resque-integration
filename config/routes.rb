Rails.application.routes.draw do
  namespace :resque do
    namespace :queues do
      resource :info, only: :show, controller: :info
      resource :status, only: :show, controller: :status
    end
  end

  get '/_job_(/:id)', to: 'resque/jobs#show', as: 'job_status'
end
