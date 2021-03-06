class Adherent < ActiveRecord::Base
  include BCrypt
  include ActsAsContact
  delegate :email, to: :default_contact

  TYPE_PIECE = {
      carte_nationale_identite: 0,
      passeport: 1
  }

  SEXE = { 'Masculin' => 1, 'Feminin' => 2 }

  MATRIMONIAL = {
      "Célibataire" => 1,
      "Marié(e)" => 2,
      "Divorcé(e)" => 3,
      "Veuf(ve)" => 4
  }

  STATUS = {'En attente' => 1, 'Actif' => 2, 'Suspendu' => 3, 'Supprimé' => 4}

  enum affiliation: [:fils, :fille, :epoux, :epouse, :aucune_relation]
  enum type_piece_identite: TYPE_PIECE

  has_and_belongs_to_many :tags
  belongs_to :parrain, foreign_key: :parrain_id, class_name: Adherent
  has_many :adherents, foreign_key: :parrain_id
  has_many :ordonnances
  has_many :consultations
  belongs_to :default_contact, foreign_key: :contact_id, class_name: Contact
  belongs_to :groupe
  belongs_to :structure_assurance
  has_many :souscriptions
  has_many :formules, through: :souscriptions

  before_create :encrypt_password
  before_create :generate_matricule
  before_create :set_status
  after_create :set_default_contact

  validates :prenom, :nom, :date_de_naissance, :lieu_de_naissance, :sexe, :status_matrimonial, :structure_assurance_id,
            presence: true
  #validates_presence_of :password_txt, :on => :create

  #  has_secure_password
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  def self.authenticate(matricule, password_txt)
    adherent = find_by_matricule(matricule)
    if adherent && adherent.password_digest == BCrypt::Engine.hash_secret(password_txt, adherent.password_salt)
      adherent
    else
      nil
    end
  end

  def encrypt_password
    generated_password = Devise.friendly_token.first(8)
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_digest = BCrypt::Engine.hash_secret(generated_password, password_salt)
    AdherentMailer.welcome(self.email, generated_password).deliver_later
  end

  def generate_matricule
    last_adherent = Adherent.count
    current_date = Date.today.strftime('%Y%m%d')
    self.matricule = current_date+''+(last_adherent+1).to_s.rjust(6,'0')
  end

  def set_status
    self.status = 1
  end

  def full_name
    "#{prenom} #{nom}"
  end

  def set_default_contact
    self.update(default_contact: contacts.first)
  end
end
