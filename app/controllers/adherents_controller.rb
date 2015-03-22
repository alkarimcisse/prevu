class AdherentsController < ApplicationController
  before_action :set_adherent, only: [:show, :edit, :update, :destroy, :activate, :desactivate]

  def new
    @adherent = Adherent.new
    @adherent.contacts.build
    render layout: 'empty' unless user_signed_in?
  end

  def new_parrainage
    @adherent = Adherent.new
  end

  def signin
    @adherent = Adherent.new(params[:adherent])
    if @adherent.save
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new", layout: 'empty'
    end
  end
  # GET /adherents
  # GET /adherents.json
  def index
    @adherents = Adherent.all
    @q = Adherent.ransack(params[:q])
    @adherent = @q.result(distinct: true)
  end

  # GET /adherents/1
  # GET /adherents/1.json
  def show
  end

  # GET /adherents/1/edit
  def edit
  end

  def edit_parrainage
    @adherent = Adherent.find(params[:adherent_id])
  end

  # POST /adherents
  # POST /adherents.json
  def create
    @adherent = Adherent.new(adherent_params)
    generated_password = Devise.friendly_token.first(8)
    @adherent.password_digest = generated_password

    respond_to do |format|
      if @adherent.save
        format.html { redirect_to @adherent, notice: 'Adherent was successfully created.' }
        format.json { render :show, status: :created, location: @adherent }
      else
        format.html { render :new }
        format.json { render json: @adherent.errors, status: :unprocessable_entity }
      end
    end
  end

  def affiliers
    @adherents = Adherent.where('parrain_id=?', current_adherent.id)
  end

  # PATCH/PUT /adherents/1
  # PATCH/PUT /adherents/1.json
  def update
    respond_to do |format|
      if @adherent.update(adherent_params)
        format.html { redirect_to @adherent, notice: 'Adherent was successfully updated.' }
        format.json { render :show, status: :ok, location: @adherent }
      else
        format.html { render :edit }
        format.json { render json: @adherent.errors, status: :unprocessable_entity }
      end
    end
  end

  def activate
    @adherent.update(status: 2, last_activation: Time.now)
    redirect_to @adherent
  end

  def desactivate
    @adherent.update(status: 3, last_suspension: Time.now)
    redirect_to @adherent
  end

  # DELETE /adherents/1
  # DELETE /adherents/1.json
  def destroy
    @adherent.status = 4
    @adherent.last_delete = Time.now
    @adherent.save
    respond_to do |format|  
      format.html { redirect_to adherents_url, notice: 'Adherent was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_adherent
      @adherent = Adherent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def adherent_params
      params.require(:adherent).permit(:nom, :prenom, :email, :status_matrimonial, :date_de_naissance, :lieu_de_naissance,
                                       :type_piece_identite, :numero_piece_identite,:avatar,
                                       :sexe, :parrain_id, :affiliation, :groupe_id,
                                       :contacts_attributes => [:telephone, :adresse, :email])
    end
end
