class DevicesController < ApplicationController
  before_action :set_device, only: [:show, :edit, :update, :destroy, :approve]

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
    respond_to do |format|
      format.html { redirect_to devices_url, notice: 'Great success. Device was successfully destroyed.' }
      format.json { head :no_content }
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
end
