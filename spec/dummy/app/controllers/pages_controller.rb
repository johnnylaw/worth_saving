class PagesController < ApplicationController
  def new
    @page = Page.new user: current_user

    render template: 'records/form'
  end

  def edit
    @page = Page.find params[:id]

    render template: 'records/form'
  end

  private

  def current_user
    User.first
  end
end