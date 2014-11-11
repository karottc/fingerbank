
namespace :import do

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

      combination.process if combination.device.nil?
      count+=1

    end


  end

end
