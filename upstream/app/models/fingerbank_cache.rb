class FingerbankCache

  def self.get(key)
    if Rails.application.config.instance_cache[key]
      return Rails.application.config.instance_cache[key]
    elsif Rails.cache.read(key)
      # put it in memory so we can it hit after
      Rails.application.config.instance_cache[key] = Rails.cache.read(key)
      return Rails.cache.read(key) 
    else
      return nil
    end
  end

  def self.set(key, value)
    Rails.application.config.instance_cache[key] = value
    return Rails.cache.write(key, value)
  end

  def self.delete(key)
    Rails.application.config.instance_cache[key] = nil
    return Rails.cache.delete(key)
  end

end
