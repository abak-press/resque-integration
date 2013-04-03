# Resque::Integration

Интеграция Resque в Rails-приложения с поддержкой плагинов [resque-progress](https://github.com/idris/resque-progress), [resque-lock](https://github.com/defunkt/resque-lock) и [resque-multi-job-forks](https://github.com/stulentsev/resque-multi-job-forks).
Этот гем существует затем, чтобы избежать повторения чужих ошибок и сократить время, необходимое для включения resque в проект.

## Установка

Добавьте в `Gemfile`:
```ruby
gem 'resque-integration'
```

Добавьте в `config/routes.rb`:
```ruby
mount Resque::Integration::Application => "/_job_", :as => "job_status"
```

Вместо `_job_` можно прописать любой другой адрес. По этому адресу прогресс-бар будет узнавать о состоянии джоба.

Создайте `config/initializers/resque.rb`:
```ruby
Resque.redis = $redis
Resque.inline = Rails.env.test?
Resque.redis.namespace = "your_project_resque"
```

Если вы до сих пор не используете sprockets, то сделайте что-то вроде этого:
```bash
$ rails generate resque:integration:install
```
(результат не гарантирован, т.к. не тестировалось)

## Задачи

Создайте файл `app/jobs/resque_job_test.rb`:
```ruby
class ResqueJobTest
  include Resque::Integration

  # это название очереди, в которой будет выполняться джою
  queue :my_queue

  # с помощью unique можно указать, что задача является уникальной, и какие аргументы определяют уникальность задачи.
  # в данном случае не может быть двух одновременных задач ResqueJobTest с одинаковым первым аргументом
  # (второй аргумент может быть любым)
  unique { |id, description| [id] }

  # В отличие от обычных джобов resque, надо определять метод execute.
  #
  # Либо же вы можете определить метод perform, но первым аргументом должен быть указан meta_id (уникальный ID джоба):
  #   def self.perform(meta_id, id, description)
  #     ...
  #   end
  def self.execute(id, description)
    (1..100).each do |t|
      at(t, 100, "Processing #{id}: at #{t} of 100")
      sleep 0.5
    end
  end
end
```

## Конфигурация воркеров resque

Создайте файл `config/resque.yml` с несколькими секциями:
```yaml
# конфигурация redis
redis:
  host: bz-redis
  port: 6379
  namespace: blizko
  thread_safe: true

resque:
  interval: 5 # частота, с которой resque берет задачи из очереди в секундах (по умолчанию 5)
  verbosity: 1 # "шумность" логера (0 - ничего не пишет, 1 - пишет о начале/конце задачи, 2 - пишет все)
  log_file: "log/resque.log" # путь до log-файла от корня проекта

# переменные окружения, которые надобно передавать в resque
env:
  RUBY_HEAP_MIN_SLOTS: 2500000
  RUBY_HEAP_SLOTS_INCREMENT: 1000000
  RUBY_HEAP_SLOTS_GROWTH_FACTOR: 1
  RUBY_GC_MALLOC_LIMIT: 50000000

# конфигурация воркеров (названия воркеров являются названиями очередей)
workers:
  kirby: 2 # 2 воркера в очереди kirby
  images:
    count: 8 # 8 воркеров в очереди images
    jobs_per_fork: 250 # каждый воркер обрабатывает 250 задач прежде, чем форкается заново
    minutes_per_fork: 30 # альтернатива предыдущей настройке - сколько минут должен работать воркер, прежде чем форкнуться заново
    env: # переменные окружение, специфичные для данного воркера
      RUBY_HEAP_SLOTS_GROWTH_FACTOR: 0.5
```

Для разработки можно (и нужно) создать файл `config/resque.local.yml`, в котором можно переопределить любые параметры:
```yaml
redis:
  host: localhost
  port: 6379

resque:
  verbosity: 2

workers:
  '*': 1
```

## Запуск воркеров

Ручной запуск воркера (см. [официальную документацию resque](https://github.com/resque/resque/blob/1-x-stable/README.markdown))
```bash
$ QUEUE=* rake resque:work
```

Запуск всех воркеров так, как они сконфигурированы в `config/resque.yml`:
```bash
$ rake resque:start
```

Останов всех воркеров:
```bash
$ rake resque:stop
```

Перезапуск воркеров:
```bash
$ rake resque:restart
```

## Постановка задач в очередь

### Для задач, в который включен модуль `Resque::Integration`
```ruby
meta = ResqueJobTest.enqueue(id=2)
@job_id = meta.meta_id
```

Вот так можно показать прогресс-бар:
```haml
%div#progressbar

:javascript
  $('#progressbar').progressBar({
    url: #{job_status_path.to_json}, // адрес джоб-бэкенда (определяется в ваших маршрутах)
    pid: #{@job_id.to_json}, // job id
    interval: 1100, // частота опроса джоб-бэкэнда в миллисекундах
    text: "Initializing" // initializing text appears on progress bar when job is already queued but not started yet
  }).show();
```

### Для обычных задач Resque
```ruby
Resque.enqueue(ImageProcessingJob, id=2)
```

## Супервизор

Бывает так, что задачи завершаются внезапно (например, `kill -9` или приход OOM-киллера). Чтобы такие задачи не стали "зомби" и были завершены корректно, нужен супервизор.

Супервизор запускается при каждом деплое и висит в фоне, периодически проверяя resque на наличие мертвых воркеров.

```bash
$ rake resque:supervisor:restart
```