class CombinationsController < ApplicationController
  before_action :set_combination, only: [:show, :edit, :update, :destroy, :calculate]
  before_action :set_index_help, only: [:index, :unknown, :unrated]
  before_action :set_submit_help, only: [:new, :create]

  skip_before_filter :ensure_admin, :only => [:new, :create, :unknown, :unrated, :interogate]
  before_filter :ensure_community, :only => [:new, :create]
  before_filter :search_fields, :only => [:index, :unknown, :unrated]

  def search_fields
    @search_fields = [
      {:field => 'user_agent', :display => 'User Agent'},
      {:field => 'dhcp_vendor', :display => 'DHCP Vendor'},
      {:field => 'dhcp_fingerprint', :display => 'DhcpFingerprint'},
      {:field => 'device', :display => 'Device'},
      {:field => 'mac_vendor', :display => 'Mac vendor', :type => 'string'},
    ]
  end

  def escaped_search
    search = String.new(params[:search]) unless params[:search].nil?
    #search = search.gsub!(/[+\-"]/, ' ')
    puts search
    return search
  end

  def base_search
    @selected_fields = params[:fields]

    @search = Combination.search {paginate :page => params[:page], :per_page => 15}if @search.nil?
    if escaped_search 
      @search.build do
        fulltext escaped_search do
          fields(*params[:fields]) unless params[:fields].nil? 
        end
      end
    end
  end

  # GET /combinations
  # GET /combinations.json
  def index
    if params[:search]
      @search = escaped_search
      @selected_fields = params[:fields]
      @combinations = Combination.search(params[:search], @selected_fields).paginate(:page => params[:page])
    else
      @combinations = Combination.paginate(:page => params[:page]) 
    end
  end

  def unknown
    @help += "The unknown combinations that you see here haven't been sorted yet."
    if params[:search]
      @search = escaped_search
      @selected_fields = params[:fields]
      @combinations = Combination.search(params[:search], @selected_fields, "AND device_id IS NULL").paginate(:page => params[:page])
    else
      @combinations = Combination.unknown.paginate(:page => params[:page]) 
    end
    render 'index'
  end

  def unrated
    @help += "The unrated combinations that you see here have been submitted by the community but haven't been approved yet."
    if params[:search]
      @search = escaped_search
      @selected_fields = params[:fields]
      @combinations = Combination.search(params[:search], @selected_fields, "AND device_id IS NOT NULL AND score=0").paginate(:page => params[:page])
    else
      @combinations = Combination.unrated.paginate(:page => params[:page]) 
    end
    render 'index'
  end

  # GET /combinations/1
  # GET /combinations/1.json
  def show
  end

  # GET /combinations/new
  def new
    @combination = Combination.new
    @initial_values = {}
  end

  def calculate 
    begin
      @combination.process
      flash[:success] = "Combination was processed sucessfully. Yielded (Device='#{@combination.device.nil? ? "Unknown" : @combination.device.full_path}', Version='#{@combination.version}')"
      redirect_to :back
    rescue Exception => e
      flash[:error] = "An error happened while processing this combination. #{e.message}"
      redirect_to :back
    end
  end

  # GET /combinations/1/edit
  def edit
  end

  # POST /combinations
  # POST /combinations.json
  def create
    new_params = combination_params
    @initial_values  = {
      :user_agent_value => new_params[:user_agent_value],
      :dhcp_vendor_value => new_params[:dhcp_vendor_value],
      :dhcp_fingerprint_value => new_params[:dhcp_fingerprint_value],
      :mac_value => new_params[:mac_value],
    }
    puts "MAC : "+new_params[:mac_value]

    UserAgent.create(:value => new_params[:user_agent_value]) 
    DhcpVendor.create(:value => new_params[:dhcp_vendor_value]) 
    DhcpFingerprint.create(:value => new_params[:dhcp_fingerprint_value]) 

    new_params[:user_agent_id] = UserAgent.where(:value => new_params[:user_agent_value]).first.id
    new_params[:dhcp_vendor_id] = DhcpVendor.where(:value => new_params[:dhcp_vendor_value]).first.id
    new_params[:dhcp_fingerprint_id] = DhcpFingerprint.where(:value => new_params[:dhcp_fingerprint_value]).first.id
    mac_vendor = MacVendor.from_mac(new_params[:mac_value])
    new_params[:mac_vendor_id] = mac_vendor ? mac_vendor.id : nil

    new_params[:submitter] = @current_user

    new_params.delete(:user_agent_value)
    new_params.delete(:dhcp_vendor_value)
    new_params.delete(:dhcp_fingerprint_value)
    new_params.delete(:mac_value)

    @combination = Combination.new(new_params)
  
    respond_to do |format|
      if @combination.user_submit
        format.html { redirect_to @combination, notice: 'combination was successfully created.' }
        format.json { render :show, status: :created, location: @combination }
      else
        format.html { render :new }
        format.json { render json: @combination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /combinations/1
  # PATCH/PUT /combinations/1.json
  def update
    respond_to do |format|
      if @combination.update(combination_params)
        format.html { redirect_to @combination, notice: 'Combination was successfully updated.' }
        format.json { render :show, status: :ok, location: @combination }
      else
        format.html { render :edit }
        format.json { render json: @combination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /combinations/1
  # DELETE /combinations/1.json
  def destroy
    @combination.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Combination was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_combination
      @combination = Combination.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def combination_params
      params.require(:combination).permit(:version, :score, :user_agent_id, :dhcp_fingerprint_id, :dhcp_vendor_id, :device_id, :user_agent_value, :dhcp_fingerprint_value, :dhcp_vendor_value, :mac_value)
    end

    def set_index_help
      @help = %Q(A combination is a set composed of a DHCP fingerprint, DHCP vendor, User Agent and a MAC vendor.
        These combinations have an associated device (usually representing the OS) and OS version.
        You can submit an unknown combination using the 'Submit Combination' button.
        )
    end

    def set_submit_help
      @help = %Q(Here you can submit a combination that you have.
                 If you can't find your device in the list, feel free to add it by clicking the 'Not listed ?' link
                 Enter the information that you have for the device. If some information is missing, simply leave it empty.
      )
    end


end
