class Api::V1::StaticController < Api::ApiController
  def download
    db_fname = Rails.root.join('db', 'package', "packaged.sqlite3")
    send_file(db_fname, :filename => "packaged.sqlite3", :type => "application/x-sqlite3")
  end
end
