class Device < ActiveRecord::Base
  #self.table_name = "device"

  has_many :device, :foreign_key => :parent_id
  belongs_to :parent, :class_name => "Device"
  validate :parent_is_not_child
  validates_uniqueness_of :name

  has_many :discoverers
  has_many :combinations

  belongs_to :submitter, :class_name => "User"

  scope :top_level, -> {where('parent_id IS NULL')}
  scope :approved, -> {where(:approved => true)}
  scope :not_approved, -> {where(:approved => false)}

  before_destroy :set_combinations

  def set_combinations
    combinations.each do | combination |
      combination.device = nil
      combination.save
    end
  end

  def tree_discoverers
    discoverers = []
    top_level_parent.self_and_childs.flatten.each do |device|
      discoverers.push device.discoverers
    end
    discoverers.flatten
  end

  def level
    if parent
      return parent.level+1
    else
      return 1
    end
  end

  def top_level_parent
    tmp_parent = parent
    unless tmp_parent.nil?
      tmp_parent = parent.top_level_parent
      tmp_parent
    else
      self
    end
  end

  def parent_is_not_child
    if childs.flatten.include? self
      errors.add(:parent_id, "cannot be a child")
    end
  end

  def childs
    child_chain = []
    chain = self.device
    chain.each do |child|
      child_chain.push child._childs_recur
    end
    child_chain
  end

  def _childs_recur 
    child_chain = [self]
    chain = self.device
    chain.each do |child|
      child_chain.push child._childs_recur
    end
    child_chain
  end

  def self_and_childs
    child_chain = [self]
    child_chain.push childs
    child_chain
  end

  def not_self_and_childs
    tmp_childs = childs.flatten
    tmp_childs.push self
    tmp_not_childs = []
    Device.all.each do |pdevicesible_child|
      unless tmp_childs.include? pdevicesible_child
        tmp_not_childs.push pdevicesible_child
      end
    end
    tmp_not_childs
  end

  def parents
    parents_found = []
    next_parent = parent
    while !next_parent.nil? do
      parents_found << next_parent
      next_parent = next_parent.parent
    end
    parents_found
  end

  def full_path
    base = name+"/"
    unless parent.nil?
      base.prepend parent.full_path
    end
    base
  end

  def is_mobile?
    unless inherit
      mobile
    end

    parent_check = self
    while parent_check && parent_check.mobile.nil?
      parent_check = parent_check.parent
    end
    if parent_check
      parent_check.mobile
    else
      return false
    end
  end
end
