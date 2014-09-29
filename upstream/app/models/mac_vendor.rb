class MacVendor < ActiveRecord::Base
  has_many :combinations

  def self.from_mac(mac)
    return nil if mac.nil?
    mac.gsub!(/-/, '')
    mac.gsub!(/ /, '')
    mac.gsub!(/:/, '')
    mac = mac[0..5]
    puts mac
    return self.where(:mac => mac).first
  end

end
