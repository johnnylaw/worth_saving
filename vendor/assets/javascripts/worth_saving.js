//= require_self
//= require ./worth_saving/tinymce_init
//= require ./worth_saving/form

WorthSaving = {};

$(document).ready(function() {
  $('form[data-worth-saving-form-id]').each(function() {
    new WorthSaving.Form($(this));
  });
});

WorthSaving.prepareThirdPartyEditorsForSave = function() {
  if(typeof tinymce !== 'undefined') tinymce.triggerSave();
};