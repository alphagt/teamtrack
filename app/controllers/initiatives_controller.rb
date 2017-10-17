class InitiativesController < ApplicationController
  before_action :set_initiative, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  before_filter :require_verified
  before_filter :require_admin

  # GET /initiatives
  def index
    @initiatives = Initiative.all
    puts 'Initiatives#Index - count'
    puts @initiatives.count
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @initiatives }
    end
  end

  # GET /initiatives/1
  def show
  	@initiative = Initiative.find(params[:id])
  	@projects = Project.for_initiative(params[:id])
  	
  	 respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @initiative }
    end
  end

  # GET /initiatives/new
  def new
    @initiative = Initiative.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @initiative }
    end
  end

  # GET /initiatives/1/edit
  def edit
  end

  # POST /initiatives
  def create
    @initiative = Initiative.new(initiative_params)

    respond_to do |format|
      if @initiative.save
        format.html { redirect_to @initiative, notice: 'Initiative was successfully created.' }
        format.json { render json: @initiative, status: :created, location: @initiative }
      else
        format.html { render action: "new" }
        format.json { render json: @initiative.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /initiatives/1
  def update
    if @initiative.update(initiative_params)
      redirect_to @initiative, notice: 'Initiative was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /initiatives/1
  def destroy
    @initiative.destroy
    redirect_to initiatives_url, notice: 'Initiative was successfully destroyed.'
  end

  # GET /initiatives/1/archive
  def archive
  	@initiative = Initiative.find(params[:id])
  	@initiative.active = false
  	respond_to do |format|
      if @initiative.save
        format.html { redirect_to @initiative, notice: 'Initiative was successfully archived.' }
        format.json { head :no_content }
      else
        format.html { render action: "archive" }
        format.json { render json: @initiative.errors, status: :unprocessable_entity }
      end
    end
  end
  	
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_initiative
      @initiative = Initiative.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def initiative_params
      params.require(:initiative).permit(:fiscal, :name, :description, :active)
    end
end