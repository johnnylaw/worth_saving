//= require_self
//= require ./worth_saving/tinymce_init
//= require ./worth_saving/ckeditor_init
//= require ./worth_saving/form

WorthSaving = {};

$(document).ready(function() {
  $('form[data-worth-saving-form-id]').each(function() {
    new WorthSaving.Form($(this));
  });
});

WorthSaving.prepareThirdPartyEditorsForSave = function() {
  if(typeof tinymce !== 'undefined') tinymce.triggerSave();
  if(typeof CKEDITOR !== 'undefined') {
    for ( instance in CKEDITOR.instances )
        CKEDITOR.instances[instance].updateElement();
  }
};

WorthSaving.initializeThirdPartyEditors = function(startCountdownFn) {
  if(typeof tinymce !== 'undefined') {
    WorthSaving.tinymceInit(startCountdownFn);
  }

  if(typeof CKEDITOR !== 'undefined') {
    WorthSaving.ckeditorInit(startCountdownFn);
  }
};
