class LoginController < ApplicationController
  def login
    session[:user_id] = params[:id]
    render text: "logged in User #{params[:id]}"
  end

  def logout
    session.clear
    render text: 'User logged out'
  end
end