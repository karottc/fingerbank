class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :find_current_user

  before_filter :ensure_admin, :except => [:index, :show] 

  def find_current_user
    if session[:user_id]
      @current_user = User.find(session[:user_id])
    end
  end

  def ensure_admin
    unless @current_user && @current_user.admin?
      flash[:error] = "You need to login to access this section"
      redirect_to root_path
    end
  end

  def ensure_community
    unless @current_user
      session[:previous_page] = request.url
      redirect_to login_path
    end
  end

end
