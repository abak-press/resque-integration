# Resque::Integration

Seamless integration of resque with some useful plugins: resque-progress and resque-lock, for example.

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'resque-meta', :git => 'git://github.com/broglep-koubachi/resque-meta.git' # current master is somewhat buggy
gem 'resque-integration', :path => 'vendor/gems/resque-integration'
```

And then execute:
```bash
$ bundle
```

Add this line to your `config/routes.rb`:
```ruby
mount Resque::Integration::Application => "/_job_", :as => "job_status"
```

Create an initializer `config/initializers/resque.rb`:
```ruby
Resque.redis = $redis
Resque.inline = Rails.env.test?
Resque.redis.namespace = "your_project_resque"
```

Run built-in generator if you are still on Rails 3.0 without assets pipeline:
```bash
$ rails generate resque:integration:install
```

## Usage

Create a job `app/jobs/resque_job_test.rb`:
```ruby
class ResqueJobTest
  include Resque::Integration

  queue :my_queue

  # there shall be no two jobs with same first argument
  lock_on { |id, description| [id] }

  def self.execute(id, description)
    (1..100).each do |t|
      at(t, 100, "Processing #{id}: at #{t} of 100")
      sleep 0.5
    end
  end
end
```

Please pay your attention: if you are using Resque::Integration you should not use `perform` method in your jobs. Use its `execute` method.

Run worker:
```bash
$ QUEUE=* rake resque:work
```

Enqueue your new shiny job:
```ruby
meta = ResqueJobTest.enqueue(id=2)
@job_id = meta.meta_id
```

Show progress bar:
```haml
%div#progressbar

:javascript
  $('#progressbar').progressBar({
    url: #{job_status_path.to_json}, // path to status backend
    pid: #{@job_id.to_json}, // job id
    interval: 1100, // polling interval
    text: "Initializing" // initializing text appears on progress bar when job is already queued but not started yet
  }).show();
```

## Supervisor

This gem also contains simple supervisor script which watches for dead workers and prunes them. It can be activated with `rake resque:supervisor:start`.