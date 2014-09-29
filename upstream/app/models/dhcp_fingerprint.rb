class DhcpFingerprint < ActiveRecord::Base

  default_scope { order('value') }

  validates_uniqueness_of :value

end
