class WorthSaving::DraftsController < WorthSaving::ApplicationController
  def create
    @draft = WorthSaving::Draft.new draft_params
    save_if_authorized_and_respond
  end

  def update
    @draft = WorthSaving::Draft.find params[:id]
    @draft.attributes = draft_params
    save_if_authorized_and_respond
  end

  private

  def draft_params
    if WorthSaving::Info.attribute_whitelisting_required?
      params[:draft]
    else
      params.require(:draft).permit :recordable_id, :recordable_type, :scopeable_id, :scopeable_type, :form_data
    end
  end

  def save_if_authorized_and_respond
    authorized? ? save_and_respond : render_forbidden_error
  end

  def save_and_respond
    if @draft.save
      render json: { message: 'Draft saved', worthSavingDraft: { action: worth_saving.draft_path(@draft) } }
    else
      render json: { error: 'Unable to save draft' }
    end
  end

  def render_forbidden_error
    render status: 403, text: "Not authorized to draft this #{@draft.recordable_type}"
  end

  def authorized?
    return authorized_to_draft_record?(@draft.recordable) if @draft.recordable
    authorized_to_draft_with_scope?(@draft.scopeable)
  end

  def authorized_to_draft_record?(recordable)
    defined?(super) ? super : true
  end

  def authorized_to_draft_with_scope?(scopeable)
    defined?(super) ? super : true
  end
end
