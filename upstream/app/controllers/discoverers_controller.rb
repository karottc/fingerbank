class DiscoverersController < ApplicationController
  before_action :set_discoverer, only: [:show, :edit, :update, :destroy]
  before_action :set_index_help, only: [:index]
  before_action :set_show_help, only: [:show]

  # GET /discoverers
  # GET /discoverers.json
  def index
    @discoverers = Discoverer.all
  end

  # GET /discoverers/1
  # GET /discoverers/1.json
  def show
  end

  # GET /discoverers/new
  def new
    @discoverer = Discoverer.new
    if device_id_param
     @discoverer.device = Device.find(device_id_param) 
    end 
  end

  # GET /discoverers/1/edit
  def edit
  end

  # POST /discoverers
  # POST /discoverers.json
  def create
    @discoverer = Discoverer.new(discoverer_params)

    respond_to do |format|
      if @discoverer.save
        format.html { redirect_to @discoverer, notice: 'Discoverer was successfully created.' }
        format.json { render :show, status: :created, location: @discoverer }
      else
        format.html { render :new }
        format.json { render json: @discoverer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /discoverers/1
  # PATCH/PUT /discoverers/1.json
  def update
    respond_to do |format|
      if @discoverer.update(discoverer_params)
        format.html { redirect_to @discoverer, notice: 'Discoverer was successfully updated.' }
        format.json { render :show, status: :ok, location: @discoverer }
      else
        format.html { render :edit }
        format.json { render json: @discoverer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /discoverers/1
  # DELETE /discoverers/1.json
  def destroy
    @discoverer.destroy
    respond_to do |format|
      format.html { redirect_to discoverers_url, notice: 'Discoverer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_discoverer
      @discoverer = Discoverer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def discoverer_params
      params.require(:discoverer).permit(:description, :priority, :device_id, :version, :device_rule_ids => [], :version_rule_ids => [])
    end

    def device_id_param
      params[:device_id]
    end

    def set_index_help
      @help = %Q(The discoverers listed here are the core of Fingerbank.
                 These will parse the data that is sent to Fingerbank in order to categorize the combination of DHCP fingerprint, DHCP vendor, User Agent and MAC vendor.
      )
    end

    def set_show_help
      @help = %Q(On this page you can see the attributes that define the discoverer.
                 The priority is the amount that will be added to a device score if one of the device rules matches the combination.
                 The version is either an SQL extractor for the version or simply the version of the device when matching any version rule.
                 The device is the associated device to that discoverer. When matching it, it means the combination belongs to this device.
                 The devices rules are what matches the combination attributes and if they match then this discoverer is valid for that combination.
                 The version rules are what attributes a combination should match in order to be attributed the specified version in the discoverer.
      )
    end
end
