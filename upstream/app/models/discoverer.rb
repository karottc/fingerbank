class Discoverer < ActiveRecord::Base
  has_many :device_rules, :class_name => 'Rule', :foreign_key => 'device_discoverer_id'
  has_many :version_rules, :class_name => 'Rule', :foreign_key => 'version_discoverer_id'
  belongs_to :device

  validates_presence_of :device_id
  validates_presence_of :description
  validates :priority, :numericality => {:only_integer => true}

  def version_finder
    if self.version.nil?
      return "''"
    elsif self.version.match(/^PREG_CAPTURE/) || self.version.match(/^REPLACE/)
      return self.version
    else
      return "'#{self.version}'"
    end
  end
end
