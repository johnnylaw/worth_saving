WorthSaving.ckeditorInit = function(startCountdownFn) {
  CKEDITOR.on('instanceCreated', function(e) {
    e.editor.on('change', startCountdownFn);
  });
};
