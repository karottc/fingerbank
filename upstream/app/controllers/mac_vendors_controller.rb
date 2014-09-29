class MacVendorsController < ApplicationController
  before_action :set_mac_vendor, only: [:show, :edit, :update, :destroy]

  # GET /mac_vendors
  # GET /mac_vendors.json
  def index
    @mac_vendors = MacVendor.all
  end

  # GET /mac_vendors/1
  # GET /mac_vendors/1.json
  def show
  end

  # GET /mac_vendors/new
  def new
    @mac_vendor = MacVendor.new
  end

  # GET /mac_vendors/1/edit
  def edit
  end

  # POST /mac_vendors
  # POST /mac_vendors.json
  def create
    @mac_vendor = MacVendor.new(mac_vendor_params)

    respond_to do |format|
      if @mac_vendor.save
        format.html { redirect_to @mac_vendor, notice: 'Mac vendor was successfully created.' }
        format.json { render :show, status: :created, location: @mac_vendor }
      else
        format.html { render :new }
        format.json { render json: @mac_vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mac_vendors/1
  # PATCH/PUT /mac_vendors/1.json
  def update
    respond_to do |format|
      if @mac_vendor.update(mac_vendor_params)
        format.html { redirect_to @mac_vendor, notice: 'Mac vendor was successfully updated.' }
        format.json { render :show, status: :ok, location: @mac_vendor }
      else
        format.html { render :edit }
        format.json { render json: @mac_vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mac_vendors/1
  # DELETE /mac_vendors/1.json
  def destroy
    @mac_vendor.destroy
    respond_to do |format|
      format.html { redirect_to mac_vendors_url, notice: 'Mac vendor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mac_vendor
      @mac_vendor = MacVendor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mac_vendor_params
      params.require(:mac_vendor).permit(:name, :mac)
    end
end
