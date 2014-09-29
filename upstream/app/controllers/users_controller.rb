class UsersController < ApplicationController
  before_action :set_user, only: [:show, :promote_admin, :demote_admin, :generate_key]
  
  skip_before_filter :ensure_admin

  before_filter :admin_or_current_user
  skip_before_filter :admin_or_current_user, :only => [:login]

  def admin_or_current_user
    unless @current_user == @user || ensure_admin
      flash[:error] = "You need to login to access this user"
      redirect_to root_path
    end
  end

  def show
  end

  def login
    unless session[:previous_page]
      session[:previous_page] = request.referer 
    end
    redirect_to '/auth/github'
  end

  def promote_admin
    if @user.promote_admin
      flash[:success] = "User promoted to admin"
    else
      flash[:error] = "Couldn't promote the user to an admin"
    end
    redirect_to users_path
  end

  def demote_admin
    if @user.demote_admin
      flash[:success] = "User demoted"
    else
      flash[:error] = "Couldn't demote the user" 
    end
    redirect_to users_path
  end

  def generate_key
    @user.generate_key
    if @user.save
      flash[:success] = "Generated key #{@user.key}"
    else
      flash[:error] = "Can't generate key"
    end
    redirect_to :back
  end

  def index
    @users = User.all
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name)
    end


end
