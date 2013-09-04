#Example unsaved recordable
params = {
  worth_saving_recordable: {
    type: 'Page',
    id: '',
    info: {
      user_id: 2,
      title: 'New Page',
      content: 'Some stuff that was on the page'
    }
  }
}

#Example saved recordable
params = {
  worth_saving_recordable: {
    type: 'Page',
    id: '5342',
    info: {
      user_id: 2,
      title: 'New Page',
      content: 'Some stuff that was on the page'
    }
  }
}

class WorthSavingDraftsController
  def create_or_update
    @worth_saving_draft = WorthSavingDraft.find_or_build params[:worth_saving_recordable]
    if @worth_saving_draft.save
      render json: { success: true }
    else
      render json: { errors: @worth_saving_draft.errors }
    end
  end
  # The create_or_update action doesn't know whether draft has been created or not
  # Alternatively could have two actions and have jQuery inject the ID
  #    of the WorthSavingDraft into the subsequent calls and making them
  #    PUT rather than POST.  Then draft can be looked up easily in PUT
  #    route and created in POST route all RESTful-like
  # Then all the determination of whether to save a record or not would lie
  #    in validations, WorthSavingDraft would belong_to :recordable and :scopeable
  # Permissions become interesting, as controller would need to know how to
  #    ascertain the ownership of the recordable (or scopeable or draft itself), which
  #    would require some writing of boilerplate, so programmer could write:
  #      verify_ownership_of_recordable @worth_saving_draft.recordable and
  #      verify_ownership_of_scopeable @worth_saving_draft.scopeable and/or
  #      verify_ownership_of_draft @worth_saving_draft
  #    any of which would be tricky.  Developers would have to implement
  #    a method like can_be_edited_by?(user) in models that would be affected,
  #    which means scopes as well as worth_saving models. Maybe good to check out cancan
  #    and use methods such as they create to make it easy for people using
  #    cancan
  #
  #    Validations would include recordable info being all in place or
  #    scopeable information and recordable_type being in place, possibly even
  #    making sure that if all are in place that the recordable actually belongs to
  #    the scopeable
  def create
    # jQuery grabs ID out of JSON response and changes submit route and method of
    #    subsequent requests.  Also need to add a callback on save that deletes
    #    worth_saving_draft (this on worth_saving models)
    @worth_saving_draft = WorthSavingDraft.new params[:worth_saving_draft]
    if @worth_saving_draft.save
      render json: { success: true, worth_saving_draft: @worth_saving_draft }
    else
      render json: { errors: @worth_saving_draft.errors }
    end
  end
  params = {
    worth_saving_draft: {
      recordable_id: '' or '3532',
      recordable_type: 'Page',
      scopeable_id: '2',
      scopeable_type: 'user',
      info: {
        title: 'New Page',
        content: 'asdfafsd'
      }
    }
  }

  def update
    @worth_saving_draft = WorthSavingDraft.find params[:id]
    if @worth_saving_draft.update_attributes params[:worth_saving_draft]
    else
    end
  end

end

class WorthSavingDraft
  def self.find_or_build(recordable_params)
    # Verify class is registered
    record_class = worth_saving_class_with_name recordable_params[:type]
    raise 'Trying to make a draft for an unregistered class' unless record_class

    # Find or build recordable
    recordable = if recordable_params[:id].present?
      record_class.find recordable_params[:id]
    else
      record_class.new
    end

    # Find or build draft
    draft = recordable.worth_saving_draft || recordable.build_worth_saving_draft
    draft.info = recordable_params[:info].to_json


    # Could be three separate methods
    record_class = find_registered_recordable_class recordable_params[:type]
    recordable = find_or_build_new_recordable record_class, recordable_params[:id]
    draft = find_or_build_draft_with_info recordable, recordable_params[:info]
  end

  # All of this needs to be relatively invisible. Possibly try
  include WorthSaving::WorthSavingDraft
end

module WorthSaving
  module ActiveRecordExt
    def self.build_worth_saving_draft(params)
      return super if persisted?
      build_worth_saving_draft_by_scopeable params
    end

    def self.build_worth_saving_draft_by_scopeable(params)
      WorthSavingDraft.new params.merge(
        scopeable_id: params[worth_saving_scopeable_foreign_key],
        scopeable_type: worth_saving_scope_class.name,
        recordable_type: self.class.name
      )
    end
  end
end