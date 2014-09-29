class DhcpVendor < ActiveRecord::Base


  validates_uniqueness_of :value

end
