class DhcpFingerprintsController < ApplicationController
  before_action :set_dhcp_fingerprint, only: [:show, :edit, :update, :destroy]

  # GET /dhcp_fingerprints
  # GET /dhcp_fingerprints.json
  def index
    @dhcp_fingerprints = DhcpFingerprint.all
  end

  # GET /dhcp_fingerprints/1
  # GET /dhcp_fingerprints/1.json
  def show
  end

  # GET /dhcp_fingerprints/new
  def new
    @dhcp_fingerprint = DhcpFingerprint.new
  end

  # GET /dhcp_fingerprints/1/edit
  def edit
  end

  # POST /dhcp_fingerprints
  # POST /dhcp_fingerprints.json
  def create
    @dhcp_fingerprint = DhcpFingerprint.new(dhcp_fingerprint_params)

    respond_to do |format|
      if @dhcp_fingerprint.save
        format.html { redirect_to @dhcp_fingerprint, notice: 'DhcpFingerprint was successfully created.' }
        format.json { render :show, status: :created, location: @dhcp_fingerprint }
      else
        format.html { render :new }
        format.json { render json: @dhcp_fingerprint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dhcp_fingerprints/1
  # PATCH/PUT /dhcp_fingerprints/1.json
  def update
    respond_to do |format|
      if @dhcp_fingerprint.update(dhcp_fingerprint_params)
        format.html { redirect_to @dhcp_fingerprint, notice: 'DhcpFingerprint was successfully updated.' }
        format.json { render :show, status: :ok, location: @dhcp_fingerprint }
      else
        format.html { render :edit }
        format.json { render json: @dhcp_fingerprint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dhcp_fingerprints/1
  # DELETE /dhcp_fingerprints/1.json
  def destroy
    @dhcp_fingerprint.delete
    respond_to do |format|
      format.html { redirect_to dhcp_fingerprints_url, notice: 'DhcpFingerprint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dhcp_fingerprint
      @dhcp_fingerprint = DhcpFingerprint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dhcp_fingerprint_params
      params[:dhcp_fingerprint]
    end
end
