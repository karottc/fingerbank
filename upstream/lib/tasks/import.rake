require 'iconv'

namespace :import do

  task :android_models, [:file_path] => [:environment] do |t, args|
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    if args[:file_path].nil?
      puts "No file specified. Exiting"
      next
    end
  
    line_num=0
    text=File.open('tmp/android_models.txt').read
    text.gsub!(/\r\n?/, "\n")
    state = "looking_for_manufacturer"
    manufacturer = ""
    generic_android = Device.where(:name => "Generic Android").first
    count = 0
    text.each_line do |line|
      line.gsub!(/\n/, "")
      line.gsub!(/^ */, "")
      #puts "LINE = #{line}"
      #puts "MANUFACTURER = #{manufacturer}"
      #puts "STATE = #{state}"
      #$stdin.read
      if state == "looking_for_manufacturer" and !line.empty?
        state = "looking_for_device"
        #manufacturer = line
        manufacturer = Device.where('lower(name) = ?',  "#{line} Android".downcase).first
        if manufacturer.nil?
          puts "Manufacturer #{line} Android doesn't exists"
          manufacturer = Device.create!(:name => "#{line} Android", :parent => generic_android, :inherit => true)
          puts "Created manufacturer #{manufacturer.name}"
        else
          puts "Manufacturer #{manufacturer.name} exists"
        end
      elsif state == "looking_for_device" or state=="parsing_devices" and !line.empty?
        state = "parsing_devices"
        count += 1
        puts "#{line}"
        data = line.split('(')
        name = data[0]
        name = ic.iconv(name + ' ')[0..-2]
        name.gsub!(/ *$/, "")
        puts "'#{name}'"

        device = Device.where('lower(name) = ?', name.downcase).first
        if device.nil?
          puts "Device #{name} doesn't exist yet. Creating it"
          device = Device.create!(:name => name, :parent => manufacturer, :inherit => true)
        else
          puts "Device #{name} exists"
        end

        unless data[1].nil?
          model_info = data[1].split('/')
          unless model_info[1].nil?
            model_number = model_info[1].sub(/\)/, '') 
            model_number = model_number.sub('\'', '\'\'') 
            model_number = ic.iconv(model_number + ' ')[0..-2]
            discoverer = Discoverer.where(:device => device).where("lower(description) = ?", "#{name} from model # on User Agent".downcase).first
            unless discoverer.nil?
              rule_already_in = false
              discoverer.device_rules.each do |rule|
                if rule.value == "user_agents.value LIKE '% #{model_number} %'"
                  rule_already_in = true
                  break
                end
              end
    
              unless rule_already_in
                puts "Adding rule for model # #{model_number} to device #{device.name}"
                rule = Rule.create!(:value => "user_agents.value LIKE '% #{model_number} %'", :device_discoverer => discoverer)
              end
            else
              discoverer = Discoverer.create!(:description => "#{name} from model # on User Agent", :priority => 5, :device => device)
              puts "Adding rule for model # #{model_number} to device #{device.name}"
              rule = Rule.create!(:value => "user_agents.value LIKE '% #{model_number} %'", :device_discoverer => discoverer)
            end

          end
        end

      elsif state == "parsing_devices" and line.empty?
        state = "looking_for_manufacturer"
      end
    end

    puts count
   
  end



  task :merge_stats, [:db_path] => [:environment] do |t, args|

    # what is the last inserted that has no owner (should be by this script)
    last_inserted = Combination.where(:submitter_id => nil).order(created_at: :desc).first
    # the stats database uses the local time at Inverse inc.
    last_inserted_time = Time.now.in_time_zone("Eastern Time (US & Canada)") 
    puts last_inserted_time

    if args[:db_path].nil?
      puts "No database specified. Exiting"
      next
    end

    orig = SQLite3::Database.open args[:db_path]

    stm = orig.prepare "select count(*) as total_count from stats_dhcp left outer join stats_http on stats_dhcp.mac=stats_http.mac"

    result = stm.execute

    total_count = 0
    result.each do |row| total_count = row[0] end

    stm = orig.prepare "select stats_dhcp.mac, stats_dhcp.dhcp_fingerprint, stats_dhcp.vendor_id, stats_http.user_agent from stats_dhcp left outer join stats_http on stats_dhcp.mac=stats_http.mac"

    result = stm.execute

    count = 0
    result.each do |row|
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')

      puts "Processing #{row[0]} #{count}/#{total_count}"

      mac_value = ic.iconv(row[0] + ' ')[0..-2][0..7]
      dhcp_fingerprint_value = row[1].nil? ? '' : ic.iconv(row[1] + ' ')[0..-2]
      dhcp_vendor_value = row[2].nil? ? '' : ic.iconv(row[2] + ' ')[0..-2]
      user_agent_value = row[3].nil? ? '' : ic.iconv(row[3] + ' ')[0..-2]
      DhcpFingerprint.create(:value => dhcp_fingerprint_value)
      dhcp_fingerprint = DhcpFingerprint.where(:value => dhcp_fingerprint_value).first
      UserAgent.create(:value => user_agent_value)
      user_agent = UserAgent.where(:value => user_agent_value).first
      DhcpVendor.create(:value => dhcp_vendor_value)
      dhcp_vendor = DhcpVendor.where(:value => dhcp_vendor_value).first 

      combination = Combination.new
      combination.dhcp_fingerprint = dhcp_fingerprint
      combination.user_agent = user_agent
      combination.dhcp_vendor = dhcp_vendor
      combination.mac_vendor = MacVendor.from_mac(mac_value)
      combination.save
      combination = Combination.where(:user_agent => user_agent, :dhcp_fingerprint => dhcp_fingerprint, :dhcp_vendor => dhcp_vendor, :mac_vendor => combination.mac_vendor).first

      count+=1

    end


  end

end
