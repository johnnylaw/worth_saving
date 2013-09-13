class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    User.find 2
  end

  def authorized_to_draft_record?(record)
    can? :manage, record
  end

  def authorized_to_draft_with_scope?(scope)
    can? :add_records, scope
  end

  private

  def can?(action, record)
    return current_user.id == record.owner.id if record.respond_to?(:owner)
    current_user == record
  end
end
