class StructureAssurance < ActiveRecord::Base
  include Activable
  include ActsAsContact

  has_attached_file :logo, styles: { medium: '300x300>', thumb: '100x100>'}
  validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/

  belongs_to :structure, polymorphic: true
  has_many :formules
  has_many :adherents

  validates :nom, presence: true
end
