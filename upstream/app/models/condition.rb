class Condition < ActiveRecord::Base
  belongs_to :rule

  validates_presence_of :key
  validates_presence_of :value
end
