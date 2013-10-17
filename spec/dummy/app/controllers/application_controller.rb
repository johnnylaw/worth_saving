class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :editor, :form

  def current_user
    @current_user ||= session[:user_id] ? User.find(session[:user_id]) : nil
  end

  def editor
    @editor ||= params[:editor] || session[:editor]
    session[:editor] = @editor
  end

  def form
    @form ||= params[:form] || session[:form]
    @form = 'form' if @form.blank?
    session[:form] = @form
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