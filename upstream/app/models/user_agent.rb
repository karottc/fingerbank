class UserAgent < ActiveRecord::Base

  has_many :combinations

  validates_uniqueness_of :value

end
