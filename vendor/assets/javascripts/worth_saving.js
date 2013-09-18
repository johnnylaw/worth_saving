//= require_self
//= require_tree .

WorthSaving = {};

$(document).ready(function() {
  $('form[data-worth-saving-form-id]').each(function() {
    new WorthSaving.Form($(this));
  });
});