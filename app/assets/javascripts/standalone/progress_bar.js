//модуль для показа прогресс-бара создания отчетов

app.modules.progressBar = (function(self) {

  function _requestError(data) {
    var payload = data.payload;

    if (app.config.progressBar.documentLocationError) {
      alert('Ошибка');
      location.href = app.config.progressBar.documentLocationError;
    }

    if (payload && payload.error_messages) {
      $('.js-pberrors').html(payload.error_messages.join('<br>'));
    }
  }

  function _requestSuccess(data) {
    var
      progress = data.progress;

    if (progress && progress.message) {
      $('.js-pbstat').text(progress.num + ' из ' + progress.total + ' (' + Math.round(progress.percent) + '%)');
    }
  }

  function _init() {
    $('.js-progressbar').progressBar({
      url: app.config.progressBar.url,
      pid: app.config.progressBar.pid,
      onSuccess: function() {
        location.href = app.config.progressBar.documentLocation;
      },
      onError: function(data) {
        _requestError(data);
      },
      onRequestSuccess: function(data) {
        _requestSuccess(data);
      }
    });
  }

  self.load = function() {
    _init();
  };
  return self;
}(app.modules.progressBar || {}));
