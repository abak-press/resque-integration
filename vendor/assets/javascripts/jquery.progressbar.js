/*
 * ProgressBar v. 1.0.0
 * 2012-11-25 
 *
 * jQuery плагин для отображения прогресс-бара
 *
 * События: 
 * onSuccess(data) - задача успешно завершена
 * onError(data) - случилась ошибка
 * onRequestComplete - запрос к серверу завершен
 * onRequestSuccess - запрос к серверу завершен успешно
 * onRequestError - запрос к серверу завершен с ошибкой
 *
 */

(function($) {
  var 
    _options = {},
    _defaults = {
      url: '',
      pid: '', //если pid указан то он присоединяется к url по правилу: url/pid
      max: 0,
      value: 0,
      text: '', 
      form: 'progress', //внешний вид прогресс-бара (прогресс-бар, заполняющийся по мере выполнения задачи 'progress', прогресс-бар без индикации процесса выполнения 'load')
      interval: 1000, //интервал запроса к серверу в миллисекундах
      disabled: false, //первоначальное состояние прогресс-бара
      typeRequest: 'GET', //тип запроса к серверу
      waitRequestComplete: true, //ждать ответа от сервера и до этого времени не делать новых запросов
      classProgressBar: 'progress-bar',
      classProgressBarLabel: 'progress-bar-label',
      classProgressBarContainer: 'progress-bar-container'
    },

    _getOptions = function($element) {
      return $element.data('options');
    },

    _setOptions = function($element, option, value) {
      var item = {};
      item[option] = value;
      $element.data('options', $.extend($element.data('options'), item));
    },

    _start = function($element) {
      var options = _getOptions($element);
      if (options.intervalId) {
        return;
      }
      _request($element);
      options.intervalId = setInterval(function() { 
        if (!options.request || !options.waitRequestComplete) {
          _request($element); 
        }
      }, options.interval);
      _setOptions($element, 'intervalId', options.intervalId);
      options.onEnable && options.onEnable();
    },

    _stop = function($element) {
      var options = _getOptions($element);
      clearInterval(options.intervalId);
      _setOptions($element, 'intervalId', 0);
      options.onDisable && options.onDisable();
    },

    _render = function($element) {
      var 
        options = _getOptions($element),
        $bar = $('<div>').addClass(options.classProgressBar),
        $label = $('<div>').addClass(options.classProgressBarLabel).html(options.text);

      switch (options.form) {
        case 'progress': 
          $bar.width(options.value / options.max * $element.width());
          $element.empty().append($bar, $label);
        break;
        case 'load': 
          $bar.width($element.width());
          $element.empty().append($bar, $label);
        break;
      }
    },
      
    _request = function($element) {
      var options = _getOptions($element);
      _setOptions($element, 'request', true);
      $.ajax({
        url: options.url + (options.pid ? '/' + options.pid : ''),
        type: options.typeRequest,
        dataType: 'json',
        cache: false,
        complete: function() {
          _setOptions($element, 'request', false);
          options.onRequestComplete && options.onRequestComplete();
        },
        success: function(data) {
          _setOptions($element, 'value', data.progress.num);
          _setOptions($element, 'max', data.progress.total);
          data.started_at && _setOptions($element, 'text', data.progress.message);

          _render($element);

          if (data.succeeded || data.failed) {
            _stop($element);
            data.succeeded && options.onSuccess && options.onSuccess(data);
            data.failed && options.onError && options.onError(data);
          } 
          options.onRequestSuccess && options.onRequestSuccess(data);
        },
        error: function(e) {
          _stop($element);
          options.onRequestError && options.onRequestError(e);
        }
      });
    },

    _create = function($container) {
      $container.each(function() { 
        var
          $this = $(this).data('options', $.extend({}, _options)),
          options = _getOptions($this);

        $this.addClass(options.classProgressBarContainer).show().html(options.text);        
        !options.disabled && _start($this);
      });      
    },

    //методы плагина
    _methods = {
      init: function(options) {
        _options = {};
        $.extend(_options, _defaults, options); 
        _create(this); 
        return this;
      },
      disable: function() {
        _stop(this);
        return this;
      },
      enable: function() {
        _start(this);
        return this;
      },
      option: function() {
        return _getOptions(this);
      },
      value: function(value) {
        if (value === undefined) {
          return _getOptions(this).value;
        } else {
          _setOptions(this, 'value', value);
          _render(this);
        }
      },
      text: function(value) {
        if (value === undefined) {
          return _getOptions(this).text;
        } else {
          _setOptions(this, 'text', value);
          _render(this);
        }
      }

    };
             
  $.fn.progressBar = function(method) {
    if (typeof method === 'object' || !method) {
      return _methods.init.apply(this, arguments);
    }
    if (_methods[method]) {
      return _methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
    }
    $.error('Метод ' +  method + ' не существует в jQuery.progressBar');
  };

})(jQuery);