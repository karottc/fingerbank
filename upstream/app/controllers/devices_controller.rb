class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy, :approve]
  before_action :set_index_help, only: [:index]
  before_action :set_show_help, only: [:show]

  skip_before_filter :ensure_admin, :only => [:community_new, :community_create]
  before_filter :ensure_community, :only => [:community_new, :community_create]

  # GET /device
  # GET /device.json
  def index
    @devices = Device.top_level
  end

  def not_approved
    @devices = Device.not_approved
  end

  def approve
    @device.approved = true
    @device.save
    expire_device_tree @device

    flash[:notice] = "Device has been approved"
    redirect_to :back
  end

  # GET /device/1
  # GET /device/1.json
  def show
    @top_level_parent = @device.top_level_parent
  end

  def community_new
    @device = Device.new
    render 'community_new', :layout => false
  end

  def community_create
    @device = Device.new(device_params)
    @device.approved = false

    respond_to do |format|
      if @device.save
        format.html { redirect_to @device, notice: 'Great success. Device was successfully created.' }
        format.json { render json: @device}
      else
        format.html { render :new }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end

  end

  # GET /device/new
  def new
    @device = Device.new
  end

  # GET /device/1/edit
  def edit
  end

  # POST /device
  # POST /device.json
  def create
    @device = Device.new(device_params)
    if device_params[:inherit_mobile?]
      @device.mobile = nil
    end

    respond_to do |format|
      if @device.save
        expire_device_tree @device
        format.html { redirect_to @device, notice: 'Great success. Device was successfully created.' }
        format.json { render :show, status: :created, location: @device }
      else
        format.html { render :new }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /device/1
  # PATCH/PUT /device/1.json
  def update

    respond_to do |format|
      if @device.update(device_params)
        expire_device_tree(@device)
        format.html { redirect_to @device, notice: 'Great success. Device was successfully updated.' }
        format.json { render :show, status: :ok, location: @device }
      else
        format.html { render :edit }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /device/1
  # DELETE /device/1.json
  def destroy
    @device.destroy
    expire_device_tree @device
    respond_to do |format|
      format.html { redirect_to devices_url, notice: 'Great success. Device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def expire_device_tree(device)
    DevicesController.action_methods.each do |method|
      expire_fragment("#{method}-device-#{device.id}")
    end
    expire_fragment("device-selection-#{device.id}")
    device.parents.each do |parent|
      expire_device_tree(parent)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(:name, :mobile, :inherit, :tablet, :parent_id, :dhcp_fingerprint_ids => [])
    end

    def set_index_help
      @help = %Q(These are all the devices that are known to Fingerbank.
                 Click on the eye next to a device to have more information about it, including how it's discovered and the matching combinations in the database.
      )
    end

    def set_show_help
      @help = %Q(On this page you can see where the device is located in the device hierarchy and it's parents and neighbors.
                 The discoverers that find combinations belonging to that device are listed below.
                 Also listed below are the matching combinations in the Fingerbank database that belong to this device.
      )
    end
    

end
