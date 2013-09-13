class WorthSaving::DraftsController < WorthSaving::ApplicationController
  def create
    @draft = WorthSaving::Draft.new draft_params
    render_result
  end

  def update
    @draft = WorthSaving::Draft.find params[:id]
    @draft.attributes = draft_params
    render_result
  end

  private

  def draft_params
    if WorthSaving::Info.attribute_whitelisting_required?
      params[:draft]
    else
      params.require(:draft).permit :recordable_id, :recordable_type, :scopeable_id, :scopeable_type, :form_data
    end
  end

  def render_result
    if @draft.save
      render json: { message: 'Draft saved', worthSavingDraft: { action: worth_saving.draft_path(@draft) } }
    else
      render json: { error: 'Unable to save draft' }
    end
  end
end
