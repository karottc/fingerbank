class Api::V1::CombinationsController < Api::ApiController
  
  def interogate 
    require 'json'

    puts interogate_params

    if interogate_params[:user_agent].blank? && interogate_params[:dhcp_fingerprint].blank? && interogate_params[:dhcp_vendor].blank? && interogate_params[:mac].blank?
      render json: {:message => 'There is no parameter in your query'}, :status => :bad_request
      return
    end

    @combination = nil
    user_agent = UserAgent.where(:value => interogate_params[:user_agent]).first
    user_agent = UserAgent.create(:value => interogate_params[:user_agent]) unless user_agent

    dhcp_fingerprint = DhcpFingerprint.where(:value => interogate_params[:dhcp_fingerprint]).first
    dhcp_fingerprint = DhcpFingerprint.create(:value => interogate_params[:dhcp_fingerprint]) unless dhcp_fingerprint

    dhcp_vendor = DhcpVendor.where(:value => interogate_params[:dhcp_vendor]).first
    dhcp_vendor = DhcpVendor.create(:value => interogate_params[:dhcp_vendor]) unless dhcp_vendor

    mac_vendor = MacVendor.from_mac(interogate_params[:mac])
    mac_vendor_id = mac_vendor.nil? ? 'NULL' : mac_vendor.id

    matched = Combination.where("user_agent_id=#{user_agent.id} or dhcp_fingerprint_id=#{dhcp_fingerprint.id} or dhcp_vendor_id=#{dhcp_vendor.id} or mac_vendor_id=#{mac_vendor_id}")

    puts matched

    unless matched.empty?
      top = nil
      top_matched = 0
      matched = matched.sort{|a,b| a.score <=> b.score}
      matched.each do |combination|
        count = 0
        count +=1 if(user_agent == combination.user_agent && interogate_params[:user_agent])  
        count +=1 if(dhcp_fingerprint == combination.dhcp_fingerprint && interogate_params[:dhcp_fingerprint])
        count +=1 if(dhcp_vendor == combination.dhcp_vendor && interogate_params[:dhcp_vendor])
        count +=1 if(mac_vendor == combination.mac_vendor && interogate_params[:mac] && mac_vendor)
        if(count >= top_matched && count > 0)
          top = combination 
          top_matched = count
        end
      end
      @combination = top
    end

    respond_to do |format|
      unless @combination.nil?
        format.json { render 'combinations/show', status: :found, location: @combination }
        Thread.new do
          Combination.create(:user_agent => user_agent, :dhcp_fingerprint => dhcp_fingerprint, :dhcp_vendor => dhcp_vendor, :mac_vendor => mac_vendor, :device => @combination.device)  
        end
      else
        format.json { render json: {:message => 'Not found. Will process. Try again in a few moments'}, :status => :not_found }
        Thread.new do
          combination = Combination.create(:user_agent => user_agent, :dhcp_fingerprint => dhcp_fingerprint, :dhcp_vendor => dhcp_vendor, :mac_vendor => mac_vendor)
          combination.calculate
        end
      end
    end
  end

  private
    def interogate_params
      params.permit(:user_agent, :dhcp_fingerprint, :dhcp_vendor, :mac)
    end

end
