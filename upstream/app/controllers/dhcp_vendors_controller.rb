class DhcpVendorsController < ApplicationController
  before_action :set_dhcp_vendor, only: [:show, :edit, :update, :destroy]

  # GET /dhcp_vendors
  # GET /dhcp_vendors.json
  def index
    @dhcp_vendors = DhcpVendor.all
  end

  # GET /dhcp_vendors/1
  # GET /dhcp_vendors/1.json
  def show
  end

  # GET /dhcp_vendors/new
  def new
    @dhcp_vendor = DhcpVendor.new
  end

  # GET /dhcp_vendors/1/edit
  def edit
  end

  # POST /dhcp_vendors
  # POST /dhcp_vendors.json
  def create
    @dhcp_vendor = DhcpVendor.new(dhcp_vendor_params)

    respond_to do |format|
      if @dhcp_vendor.save
        format.html { redirect_to @dhcp_vendor, notice: 'Dhcp vendor was successfully created.' }
        format.json { render :show, status: :created, location: @dhcp_vendor }
      else
        format.html { render :new }
        format.json { render json: @dhcp_vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dhcp_vendors/1
  # PATCH/PUT /dhcp_vendors/1.json
  def update
    respond_to do |format|
      if @dhcp_vendor.update(dhcp_vendor_params)
        format.html { redirect_to @dhcp_vendor, notice: 'Dhcp vendor was successfully updated.' }
        format.json { render :show, status: :ok, location: @dhcp_vendor }
      else
        format.html { render :edit }
        format.json { render json: @dhcp_vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dhcp_vendors/1
  # DELETE /dhcp_vendors/1.json
  def destroy
    @dhcp_vendor.destroy
    respond_to do |format|
      format.html { redirect_to dhcp_vendors_url, notice: 'Dhcp vendor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dhcp_vendor
      @dhcp_vendor = DhcpVendor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dhcp_vendor_params
      params.require(:dhcp_vendor).permit(:value)
    end
end
