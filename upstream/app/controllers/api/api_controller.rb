class Api::ApiController < ApplicationController
  skip_before_filter :ensure_admin

  before_filter :validate_key

  def validate_key
    if params[:key].nil?
      render :json => "Missing key", :status => :unauthorized
      return
    end

    user = User.where(:key => params[:key]).first
    if user.nil?
      render :json => "Invalid key", :status => :unauthorized
      return
    end

    user.add_request

  end

end
