class ConfigFlagsController < ApplicationController
  # GET /config_flags
  # GET /config_flags.xml
  def index
    @config_flags = ConfigFlag.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @config_flags }
    end
  end

  # GET /config_flags/1
  # GET /config_flags/1.xml
  def show
    @config_flag = ConfigFlag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @config_flag }
    end
  end

  # GET /config_flags/new
  # GET /config_flags/new.xml
  def new
    @config_flag = ConfigFlag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @config_flag }
    end
  end

  # GET /config_flags/1/edit
  def edit
    @config_flag = ConfigFlag.find(params[:id])
  end

  # POST /config_flags
  # POST /config_flags.xml
  def create
    @config_flag = ConfigFlag.new(params[:config_flag])

    respond_to do |format|
      if @config_flag.save
        format.html { redirect_to(@config_flag, :notice => 'Config flag was successfully created.') }
        format.xml  { render :xml => @config_flag, :status => :created, :location => @config_flag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @config_flag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /config_flags/1
  # PUT /config_flags/1.xml
  def update
    @config_flag = ConfigFlag.find(params[:id])

    respond_to do |format|
      if @config_flag.update_attributes(params[:config_flag])
        format.html { redirect_to(@config_flag, :notice => 'Config flag was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @config_flag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /config_flags/1
  # DELETE /config_flags/1.xml
  def destroy
    @config_flag = ConfigFlag.find(params[:id])
    @config_flag.destroy

    respond_to do |format|
      format.html { redirect_to(config_flags_url) }
      format.xml  { head :ok }
    end
  end
end
