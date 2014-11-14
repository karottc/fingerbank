class PagesController < ApplicationController

  skip_before_filter :ensure_admin, :only => [:download, :api_doc]
  before_filter :ensure_community, :only => [:download]

  def download
  end

  def api_doc
  end

end
