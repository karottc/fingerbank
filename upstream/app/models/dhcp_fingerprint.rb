class DhcpFingerprint < ActiveRecord::Base

  has_many :combinations

  default_scope { order('value') }

  validates_uniqueness_of :value

end
