class Combination < ActiveRecord::Base
  belongs_to :dhcp_fingerprint
  belongs_to :user_agent
  belongs_to :dhcp_vendor
  belongs_to :device
  belongs_to :mac_vendor

  belongs_to :submitter, :class_name => "User"

  #validates_uniqueness_of :dhcp_fingerprint_id, :scope => [ :user_agent_id, :dhcp_vendor_id ], :message => "A combination with these attributes already exists"
  validate :validate_combination_uniqueness

  scope :unknown, -> {where(:device => nil)}   
  scope :unrated, -> {where('device_id is not null and score=0')}   

#  searchable do
#    text :dhcp_fingerprint do
#      dhcp_fingerprint ? dhcp_fingerprint.value : nil
#    end
#    text :user_agent do
#      user_agent ? user_agent.value : nil
#    end
#    text :dhcp_vendor do
#      dhcp_vendor ? dhcp_vendor.value : nil
#    end
#    text :mac_vendor do
#      mac_vendor ? mac_vendor.name : nil
#    end
#    text :device do
#      device ? device.name : nil
#    end 
#
#    integer :device_id
#
#    integer :score
#
#  end

  def self.search(what, fields, add_query = "")
    query = ""
    default_fields = ['dhcp_fingerprint', 'user_agent', 'dhcp_vendor', 'mac_vendor', 'device']
    fields = default_fields if fields.nil?
    params = []
    started = false
    fields.each do |field|
      if field == 'dhcp_fingerprint'
        to_add, value = self.add_where 'dhcp_fingerprints.value', what, started
      elsif field == 'user_agent'
        to_add, value = self.add_where 'user_agents.value', what, started
      elsif field == 'dhcp_vendor'
        to_add, value = self.add_where 'dhcp_vendors.value', what, started
      elsif field == 'mac_vendor'
        to_add, value = self.add_where 'mac_vendors.name', what, started
      elsif field == 'device'
        to_add, value = self.add_where 'devices.name', what, started
      else
        break
      end
      query += to_add
      params << value
      started = true
    end
    
    join = Combination.joins('left outer join dhcp_fingerprints on dhcp_fingerprints.id = combinations.dhcp_fingerprint_id')
    join = join.joins('left outer join user_agents on user_agents.id = combinations.user_agent_id')
    join = join.joins('left outer join dhcp_vendors on dhcp_vendors.id = combinations.dhcp_vendor_id')
    join = join.joins('left outer join mac_vendors on mac_vendors.id = combinations.mac_vendor_id')
    join = join.joins('left outer join devices on devices.id = combinations.device_id')
    
    results = join.where("(#{query}) #{add_query}", *params) 

  end

  def self.add_where(field, what, started)
    if what.end_with?('$')
      what = what.chop
    else
      what = "#{what}%"
    end

    if what.start_with?('^')
      what.slice!(0)
    else
      what = "%#{what}"
    end

    if started
      return "or #{field} like ? ", what
    else
      return "#{field} like ? ", what
    end
  end



  def validate_combination_uniqueness
    existing = Combination.where(:dhcp_fingerprint_id => dhcp_fingerprint_id, :user_agent_id => user_agent_id, :dhcp_vendor_id => dhcp_vendor_id, :mac_vendor_id => mac_vendor_id).size
    if (persisted? && existing > 1) || (!persisted? && existing > 0)
      errors.add(:combination, 'A unique set of attributes must be set. This combination already exists')
    end
  end

  def validate_submition
    if device.nil?
      errors.add(:device, 'cannot be empty')
    end
    if version.nil? or version.empty?
      errors.add(:version, 'cannot be empty')
    end
  end

  def user_submit
    validate_submition
    if errors.empty? && save
      return true
    else
      return false
    end
  end

  def process(options = {:with_version => false})
    discoverer_detected_device = nil
    new_score = nil
    discoverers_match = Combination.device_matching_discoverers[id]
    unless discoverers_match.empty?
      deepest = 0
      discoverers = discoverers_match 
      scores = Combination.score_from_discoverers discoverers
      discoverer_detected_device, new_score = (scores.sort_by {|key, value| value}).last
      puts "found #{discoverer_detected_device}"
      self.device = discoverer_detected_device 
      self.score = new_score unless new_score.nil?
    else
      puts "empty rules for #{id}"
    end 

    if options[:with_version]
      if discoverer_detected_device.nil?
        # no choice really
        # leave as is 
      else
        find_version
        puts self.device.nil? ? "Unknown device" : "Detected device "+self.device.full_path  
        puts "Score "+score.to_s
        puts version ? "Version "+version : "Unknown version"
      end
    end
    save!
  end

  def matches_discoverer?(discoverer)
    matches = []
    discoverer.device_rules.each do |rule|
      computed = rule.computed
      sql = "SELECT combinations.id from combinations 
              inner join user_agents on user_agents.id=combinations.user_agent_id 
              inner join dhcp_fingerprints on dhcp_fingerprints.id=combinations.dhcp_fingerprint_id
              inner join dhcp_vendors on dhcp_vendors.id=combinations.dhcp_vendor_id
              left join mac_vendors on mac_vendors.id=combinations.mac_vendor_id
              WHERE (combinations.id=#{id}) AND #{computed};"
      records = ActiveRecord::Base.connection.execute(sql)
      unless records.size == 0
        matches.push rule
        puts "Matched OS rule in #{discoverer.id}"
      end
    end

    discoverer.version_rules.each do |rule|
      computed = rule.computed
      sql = "SELECT combinations.id from combinations 
              inner join user_agents on user_agents.id=combinations.user_agent_id 
              inner join dhcp_fingerprints on dhcp_fingerprints.id=combinations.dhcp_fingerprint_id
              inner join dhcp_vendors on dhcp_vendors.id=combinations.dhcp_vendor_id
              left join mac_vendors on mac_vendors.id=combinations.mac_vendor_id
              WHERE (combinations.id=#{id}) AND #{computed};"
      records = ActiveRecord::Base.connection.execute(sql)
      unless records.size == 0
        matches.push rule
        puts "Matched OS rule in #{discoverer.id}"
      end
    end

    return !matches.empty?

  end

  def self.device_matching_discoverers
    # we use the unserialized cache (pretty much a global variable)
    if Rails.application.config.matching_discoverers
      return Rails.application.config.matching_discoverers
    # we fallback to the cache that lives across the instances
    elsif Rails.cache.read("device_matching_discoverers")
      Rails.application.config.matching_discoverers = Rails.cache.read("device_matching_discoverers")
      return Rails.application.config.matching_discoverers
    end

    # complete cache miss, we compute the data

    combinations = {}
    Combination.all.each do |c|
      combinations[c.id] = []
    end
    Discoverer.all.each do |discoverer|
      matches = []

      query = ""
      started = false

      discoverer.device_rules.each do |rule|
        to_add = Combination.add_condition rule.computed, started
        
        query += to_add
        started = true
      end

      unless query.empty?
        sql = "SELECT combinations.id from combinations 
                inner join user_agents on user_agents.id=combinations.user_agent_id 
                inner join dhcp_fingerprints on dhcp_fingerprints.id=combinations.dhcp_fingerprint_id
                inner join dhcp_vendors on dhcp_vendors.id=combinations.dhcp_vendor_id
                left join mac_vendors on mac_vendors.id=combinations.mac_vendor_id
                WHERE (#{query});"
        records = ActiveRecord::Base.connection.execute(sql)
        records.each do |record|
          combinations[record[0]] << discoverer
        end
        puts "Found #{records.size} hits for discoverer #{discoverer.id}"
      
      end
    end    
    # We keep our result in the cache
    success = Rails.cache.write("device_matching_discoverers", combinations)
    puts "writing cache gave #{success}"
    return Rails.cache.read("device_matching_discoverers") 
  end

  def if_for_query(query, started)
    if started
      return "IF(#{query}, 1, 0), "
    else
      return "IF(#{query}, 1, 0) "
    end
  end

  def find_matching_discoverers
    valid_discoverers = []
    temp_combination = TempCombination.create!(:dhcp_fingerprint => dhcp_fingerprint.value, :user_agent => user_agent.value, :dhcp_vendor => dhcp_vendor.value)
    ifs_started = false
    ifs = FingerbankCache.get("ifs_for_discoverers") || ""
    conditions = FingerbankCache.get("ifs_association_for_discoverers") || []

    if ifs.empty? || conditions.empty?
      ifs = ""
      conditions = []
      Discoverer.all.each do |discoverer|

        query = ""
        started = false

        discoverer.device_rules.each do |rule|
          to_add = rule.computed.gsub('dhcp_fingerprints.value', 'dhcp_fingerprint')
          to_add = to_add.gsub('user_agents.value', 'user_agent')
          to_add = to_add.gsub('dhcp_vendors.value', 'dhcp_vendor')
          to_add = Combination.add_condition to_add, started
          
          query += to_add
          started = true
        end
    
        unless query.empty?
          ifs.prepend(if_for_query(query, ifs_started))
          conditions.unshift discoverer
          ifs_started = true
        end
      end    
      success = FingerbankCache.set("ifs_for_discoverers", ifs)
      puts "wrinting ifs for discoverers gave #{success}"
      success = FingerbankCache.set("ifs_association_for_discoverers", conditions)
      puts "wrinting ifs conditions for discoverers gave #{success}"

    end

    matches = []
    unless ifs.empty?
      sql = "SELECT #{ifs} from temp_combinations 
              WHERE (id=#{temp_combination.id});"
      records = ActiveRecord::Base.connection.execute(sql)
      count = 0 
      records.each do |record|
        while !record[count].nil?
          if record[count] == 1
            discoverer = conditions[-count]
            matches.push discoverer
            puts "Matched OS rule in #{discoverer.id}"
          end
          count+=1
        end
      end

    end

    temp_combination.delete
    valid_discoverers
  end

  def find_version
    if self.device.nil?
      puts "device is nil"
      return
    end
    discoverers = device.tree_discoverers
    valid_discoverers = []
    versions_discovered = {} 
    discoverers.each do |discoverer|
      matches = []
      version_discovered = ''
      discoverer.version_rules.each do |rule|
        computed = rule.computed
        sql = "SELECT #{discoverer.version_finder} from combinations 
                inner join user_agents on user_agents.id=combinations.user_agent_id 
                inner join dhcp_fingerprints on dhcp_fingerprints.id=combinations.dhcp_fingerprint_id
                inner join dhcp_vendors on dhcp_vendors.id=combinations.dhcp_vendor_id
                left join mac_vendors on mac_vendors.id=combinations.mac_vendor_id
                WHERE (combinations.id=#{id}) AND #{computed};"
        records = ActiveRecord::Base.connection.execute(sql)
        unless records.size == 0
          matches.push rule
          puts "Matched version rule in #{discoverer.id}"
          version_discovered = records.first[0]
        end
      end
      unless matches.empty?
        valid_discoverers.push discoverer
        versions_discovered[discoverer.id] = version_discovered 
      end
    end
    version_discoverer = valid_discoverers.sort{|a,b| a.priority <=> b.priority}.last
    self.version = versions_discovered[version_discoverer.id] unless version_discoverer.nil?
  end

  def self.score_from_discoverers(discoverers)
    disc_per_device = {}
    score_per_device = {} 
    discoverers.each do |discoverer| 
      disc_per_device[discoverer.device] = [] if disc_per_device[discoverer.device].nil?
      disc_per_device[discoverer.device] << discoverer

    end
    disc_per_device.each do |device, discoverers|
      total = device.discoverers.size
      matched = discoverers.size
      
      score = 0
      discoverers.each{|discoverer| score += discoverer.priority}
      device.parents.each do |parent|
        if disc_per_device.has_key? parent
          disc_per_device[parent].each{|discoverer| score += discoverer.priority}
        end
      end
      puts device.full_path
      puts score
      score_per_device[device] = score
    end
    return score_per_device
  end

  def self.add_condition(condition, started)
    if started
      return "or #{condition} " 
    else
      return "#{condition} "
    end
  end

end

