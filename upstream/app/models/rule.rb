class Rule < ActiveRecord::Base
  has_many :conditions
  belongs_to :device_discoverer, :class_name => 'Discoverer', :foreign_key => 'device_discoverer_id'
  belongs_to :version_discoverer, :class_name => 'Discoverer', :foreign_key => 'version_discoverer_id'

  validates_presence_of :value
  validate :passes_syntax

  accepts_nested_attributes_for :conditions, :allow_destroy => true

  def passes_syntax
    true
  end

  def computed 
    tmp_value = value
    conditions.each do |condition|
      tmp_value.gsub!(Regexp.new(Regexp.escape(condition.key)), condition.value)
    end
    tmp_value
  end
end
