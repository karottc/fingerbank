class PagesController < ApplicationController

  skip_before_filter :ensure_admin, :only => [:download]
  before_filter :ensure_community, :only => [:download]

  def download
  end

end
