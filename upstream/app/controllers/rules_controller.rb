class RulesController < ApplicationController
  before_action :set_rule, only: [:show, :edit, :update, :destroy]
  before_action :set_show_help, only: [:show]

  # GET /rules
  # GET /rules.json
  def index
    @rules = Rule.all
  end

  # GET /rules/1
  # GET /rules/1.json
  def show
  end

  # GET /rules/new
  def new
    @rule = Rule.new
    if device_discoverer_id_param 
      @rule.device_discoverer = Discoverer.find(device_discoverer_id_param)
    elsif version_discoverer_id_param
      @rule.version_discoverer = Discoverer.find(version_discoverer_id_param)
    end
    @condition = Condition.new
  end

  # GET /rules/1/edit
  def edit
    @condition = Condition.new
  end

  # POST /rules
  # POST /rules.json
  def create
    @rule = Rule.new(rule_params)
    create_result = @rule.save

    condition_result = true
    unless condition_params.values.all? {|x| x.empty?}
      @condition = Condition.create(condition_params)
      @rule.conditions << @condition 
      condition_result = @rule.save
    else
      @condition = Condition.new
    end

    respond_to do |format|
      if create_result && condition_result
        format.html { redirect_to @rule, notice: 'Rule was successfully created.' }
        format.json { render :show, status: :created, location: @rule }
      else
        format.html { render :new }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
    unless condition_params.values.all? {|x| x.empty?}
      @rule.conditions << Condition.create(condition_params)
      @rule.save
    end
  end

  # PATCH/PUT /rules/1
  # PATCH/PUT /rules/1.json
  def update
    update_result = @rule.update(rule_params)

    condition_result = true
    unless condition_params.values.all? {|x| x.empty?}
      @condition = Condition.create(condition_params)
      @rule.conditions << @condition 
      condition_result = @rule.save
    else
      @condition = Condition.new
    end

    respond_to do |format|
      if update_result && condition_result 
        format.html { redirect_to @rule, notice: 'Rule was successfully updated.' }
        format.json { render :show, status: :ok, location: @rule }
      else
        format.html { render :edit }
        format.json { render json: @rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rules/1
  # DELETE /rules/1.json
  def destroy
    @rule.destroy
    respond_to do |format|
      format.html { redirect_to rules_url, notice: 'Rule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rule
      @rule = Rule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rule_params
      params.require(:rule).permit(:value, :device_discoverer_id, :version_discoverer_id, :condition_ids => [])
    end

    def condition_params
      params.require(:condition).permit(:key, :value)
    end

    # permit an version_discoverer_id to be passed for smoother creation
    def version_discoverer_id_param
      params[:version_discoverer_id]
    end

    # permit an version_discoverer_id to be passed for smoother creation
    def device_discoverer_id_param
      params[:device_discoverer_id]
    end

    def set_show_help
      @help = %Q(This page shows what the rule is matching.
                 The rules use the SQL syntax and are injected into a query to perform the match.
                 The tables available for the match are : dhcp_fingerprints, dhcp_vendors, user_agents, mac_vendors
                 For more information on the fields, refer to the SQL schema.
                 The value is the raw stored query that may contain additionnal variables that are conditions.
                 The device/version discoverer is it's associated discoverer.
                 The computed value is the end SQL that will be injected in the query.
      )
    end
end
