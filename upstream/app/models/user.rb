class User < ActiveRecord::Base
  validates_presence_of :github_uid, :name
  validates_uniqueness_of :github_uid, :display_name

  has_many :combinations, :foreign_key => "submitter_id"
  has_many :devices, :foreign_key => "submitter_id"

  scope :admins, -> {where(:level => 1)}
  scope :community, -> {where(:level => 0)}

  after_create :generate_key

  def generate_key
    require 'digest/sha1'
    self.key = Digest::SHA1.hexdigest "API-#{Time.now}-#{github_uid}"
  end

  def add_request
    if self.requests.nil?
      self.requests = 1
      save!
    else
      self.requests += 1
      save!
    end
  end

  def self.from_omniauth(auth)
    user = self.where(:github_uid => auth.uid).first
    if user 
      user.update!(:github_uid => auth.uid, :name => auth.info.nickname, :display_name => auth.info.name)
    else
      create(:github_uid => auth.uid, :name => auth.info.nickname, :display_name => auth.info.name)
    end
    return self.where(:github_uid => auth.uid).first 
  end

  def promote_admin
    update(:level => 1)
  end

  def demote_admin
    if User.admins.size > 1
      update(:level => 0)
    else
      return false 
    end
  end

  def admin?
    level >= 1
  end

end
