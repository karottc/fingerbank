
namespace :mts do
  task merge_uas: :environment do
    text=File.open('nodes.csv').read
    text.gsub!(/\r\n?/, "\n")
    orig = SQLite3::Database.open "result.db"
    text.each_line do |line|
      line.gsub!(/\n/, "")
      values = line.split(/","/)
      values[0].gsub!(/^"/, '')
      values[1].gsub!(/"$/, '')
      puts values

      stm = orig.query "insert into http(mac, UA) VALUES(?, ?);", [ values[0], values[1] ]

    end

  end

  task merge_in_db: :environment do
    
    orig = SQLite3::Database.open "result.db"
    stm = orig.prepare "select  dhcp.hash, mac.vendor, dhcp.finger,dhcp.vendor_id, http.ua, dhcp.detect, mac.mac from dhcp, http, mac where dhcp.mac=http.mac and dhcp.mac=mac.mac"

    result = stm.execute

    puts result.count

    result.each do |row|
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      dhcp_fingerprint_value = row[2].nil? ? '' : ic.iconv(row[2] + ' ')[0..-2]
      user_agent_value = row[4].nil? ? '' : ic.iconv(row[4] + ' ')[0..-2]
      dhcp_vendor_value = row[3].nil? ? '' : ic.iconv(row[3] + ' ')[0..-2]
      mac_value = row[6].nil? ? '' : ic.iconv(row[6] + ' ')[0..-2][0..7]
      puts dhcp_fingerprint_value
      puts user_agent_value
      puts dhcp_vendor_value
      puts mac_value
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
      combination = Combination.where(:user_agent => user_agent, :dhcp_fingerprint => dhcp_fingerprint, :dhcp_vendor => dhcp_vendor).first
    end


  end

end
