namespace :fbcache do
  task clear_discoverers: :environment do
    Rails.cache.delete("device_matching_discoverers")
  end

  task build_discoverers: :environment do 
    Combination.device_matching_discoverers
  end

end
