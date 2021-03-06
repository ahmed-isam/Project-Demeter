class GrantsController < ApplicationController
  before_action :set_grant, only: [:edit, :update, :destroy]
  before_action :get_project, only: [:create, :update]

  # GET /grants
  # GET /grants.json
  def index
    respond_to do |format|
      format.html { prepare_view }
      format.json { render :json => read_grants_data.to_json }
    end
  end

  # GET /grants/1
  # GET /grants/1.json
  def show
    @grant = Grant.find(params[:id])
  end

  # GET /grants/new
  def new
    @grant = Grant.new
  end

  # GET /grants/1/edit
  def edit
  end

  # POST /grants
  # POST /grants.json
  def create
    @grant = Grant.new(grant_params)
    respond_to do |format|
      if @grant.save
        format.html {
          redirect_to @grant, notice: 'Grant was successfully created.'
        }
        format.json { render :show, status: :created, location: @grant }
      else
        format.html { render :new }
        format.json {
          render json: @grant.errors, status: :unprocessable_entity
        }
      end
    end
  end

  # PATCH/PUT /grants/1
  # PATCH/PUT /grants/1.json
  def update
    respond_to do |format|
      if @grant.update(grant_params)
        format.html {
          redirect_to @grant, notice: 'Grant was successfully updated.'
        }
        format.json { render :show, status: :ok, location: @grant }
      else
        format.html { render :edit }
        format.json {
          render json: @grant.errors, status: :unprocessable_entity
        }
      end
    end
  end

  # DELETE /grants/1
  # DELETE /grants/1.json
  def destroy
    @grant.destroy
    respond_to do |format|
      format.html {
        redirect_to grants_url, notice: 'Grant was successfully destroyed.'
      }
      format.json { head :no_content }
    end
  end

  private
  def prepare_view
    @months = Array.new
    date_iterator = Date.new(2013, 1, 1)
    today = Date.today

    while date_iterator < today
      @months << date_iterator
      date_iterator = date_iterator.advance(:months => 1)
    end
  end

  def read_grants_data
    filter_date = DateTime.parse("#{params[:filter_year]}-#{params[:filter_month]}-01")

    grants = Grant.where('created_at >= ?', filter_date)
        .where('created_at <= ?', filter_date.end_of_month)

    grants = grants.where(:type_tag => params[:grant_type]) if params[:grant_type] != 'ALL'

    grants.map do |grant|
      {
          :guid => grant.GUID,
          :generator_id => grant.project.id,
          :claimant_id => grant.project.claimant.id,
          :wallet => grant.receiver_wallet,
          :type_tag => grant.type_tag,
          :amount => grant.amount
      }
    end
  end

  def set_grant
    @grant = Grant.find(params[:id])
    @grant.project_id = @grant.project.name
  end

  def get_project
    project = Project.where(:name => grant_params[:project_id]).take
    params[:grant][:project_id] = project.id
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def grant_params
    params.require(:grant).permit(:amount, :type_tag, :project_id, :receiver_wallet)
  end
end