class SessionsController < ApplicationController

  skip_before_filter :ensure_admin

  def create     
    auth_hash = request.env["omniauth.auth"]     
    user = User.from_omniauth(auth_hash)
    flash[:notice] = "You have logged in as #{user.name}"
    session[:user_id] = user.id
    redirect_to session.delete(:previous_page) || root_path
  end

  def destroy
    reset_session
    flash[:notice] = "You have logged out"
    redirect_to root_path
  end


end
