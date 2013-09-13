class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    params[:current_user_id] && User.find(params[:current_user_id])
  end
end
