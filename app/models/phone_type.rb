class PhoneType < ActiveRecord::Base
  has_many :phones

  validates :name, presence: true,       length: { maximum: 25 }

  # Type of possible phones, used in dropdowns and seed values
  NAMES = %w(Mobile Land Work Other)

end