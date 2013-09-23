WorthSaving.tinymceInit = function(startCountdownFn) {
  if(tinymce.majorVersion === '4') {
    tinymce.on('addEditor', function(obj) {
      var editor = obj.editor;
      var $field = $('#' + editor.id);
      var isWorthSaving = $field.data().worthSaving;
      if(editor !== undefined && isWorthSaving) {
        $field.off('keyup').off('change');
        editor.on('keyup change', function() {
          startCountdownFn();
        });
      }
    });
  } else {
    tinymce.onAddEditor(function(obj) {
      var editor = obj.editor;
      var $field = $('#' + editor.id);
      var isWorthSaving = $field.data().worthSaving;
      if(editor !== undefined && isWorthSaving) {
        $field.off('keyup').off('change');
        editor.onKeyUp(function() {
          startCountdownFn();
        });
        editor.onChange(function() {
          startCountdownFn();
        });
      }
    });
  }
};
