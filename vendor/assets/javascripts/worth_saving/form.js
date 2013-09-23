WorthSaving.Form = function($mainForm) {
  var formId = $mainForm.data().worthSavingFormId;
  var $draftForm = $('form[data-worth-saving-draft-form-id="' + formId + '"]')
  var countdown = false;
  var interval = parseInt($mainForm.data().worthSavingInterval) * 1000;
  var $formDataField = $draftForm.find('input[name="draft[form_data]"]');
  var $worthSavingFields = $mainForm.find('[data-worth-saving]');
  var $messageDiv = $('#worth-saving-form-message-' + formId);

  var startCountdown = function() {
    if(countdown) {
      console.log('returning because countdown is set')
      return;
    }
    console.log('starting countdown')
    countdown = true;
    setTimeout(submitDraftForm, interval);
  };

  var resetCountdown = function(){
    countdown = false;
  };

  var prepareDraftForm = function() {
    $formDataField.val($worthSavingFields.serialize());
  };

  var submitDraftForm = function() {
    WorthSaving.prepareThirdPartyEditorsForSave();
    prepareDraftForm();
    resetCountdown();
    $.ajax({
      url: $draftForm.attr('action'),
      method: "post",
      data: $draftForm.serialize(),
      accepts: "json",
      success: processSuccessfulResponse,
      error: processError
    });
  };

  var processSuccessfulResponse = function(info) {
    setDraftFormAction(info.worthSavingDraft.action);
    displayMessage(info.message, info.error !== undefined);
  };

  var processError = function(info) {
    displayMessage(info.responseText || 'Unable to save draft', true);
  };

  var setDraftFormAction = function(action) {
    $draftForm.attr('action', action);
    $draftForm.find('input[name="_method"]').remove();
    $draftForm.append('<input type="hidden" name="_method" value="put" />');
  }

  var displayMessage = function(msg, isError) {
    $messageDiv.fadeIn(500).removeClass('error').html(msg);
    if(isError) {
      $messageDiv.addClass('error');
    } else {
      $messageDiv.fadeOut(2000);
    }
  };

  $worthSavingFields.on('keyup change', function() {
    startCountdown();
  });

  if(typeof tinymce !== 'undefined') {
    WorthSaving.tinymceInit(startCountdown);
  }
};

