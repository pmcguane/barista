class Merchant < ActiveRecord::Base

  has_one :account, dependent: :destroy

  belongs_to :merchant_type
  belongs_to :state

  has_many :orders
  has_many :users, through: :orders
  has_many :trading_hours, dependent: :destroy

  has_many    :phones,          dependent: :destroy,       as: :phoneable
  has_one     :primary_phone, -> { where(primary: true) }, as: :phoneable, class_name: 'Phone'

  # Allows Products to be allocated to a Merchant
  has_many :merchant_products
  has_many :products, through: :merchant_products

  # before_validation :sanitize_data
  after_create :add_trading_hours
  geocoded_by :full_address               # can also be an IP address
  after_validation :geocode          # auto-fetch coordinates

  validates :terms_of_service, acceptance: true
  validates :name,        presence: true,       length: { maximum: 255 }
  validates :email,       format: { with: CustomValidators::Emails.email_validator },       :length => { :maximum => 255 }

  validates_presence_of :product_ids

  accepts_nested_attributes_for :trading_hours
  accepts_nested_attributes_for :merchant_products
  accepts_nested_attributes_for :phones, :reject_if => lambda { |t| ( t['display_number'].gsub(/\D+/, '').blank?) }
  accepts_nested_attributes_for :account, reject_if: :all_blank

  # @param [Object] day
  # @param [Object] hour
  def opening_status(day, hour)
    today_trading_hours = trading_hours.open_now(day, hour)
    if today_trading_hours.size > 0
      "Opened until #{today_trading_hours.first.close_time}"
    else
      "Closed"
    end
  end

  def open(day, hour, merchant)
    today_trading_hours = TradingHour.where("weekday = ? AND open_time > ? AND close_time < ? and merchant_id = ?", day, hour, hour, merchant)
    if today_trading_hours.size > 0
      "Opened until #{today_trading_hours.first.close_time}"
    else
      "Closed"
    end
  end

  def number_of_products
    # self.variants.product.group('products.id').count
    self.products.count(:id, :distinct => true)
  end

  # def self.find_by_product_types(product_type_id)
  #   # return [] if product_type_id.nil?
  #
  #   product_type = PropertySet.find_by_id product_type_id
  #   product_types = product_type.self_and_descendants.map(&:id) if product_type
  #
  #   # return if @@property_sets.nil?
  #   # self.active
  # # else
  #   self.where product_type_id: product_types
  # end

  def full_address
    [self.address, self.city, self.postal_code].reject(&:blank?).join(', ')
  end

  def add_trading_hours
    (0..6).each do |i|
      TradingHour.create!(merchant_id: self.id, weekday: i, open_time: '9:00', close_time: '17:00', active: true)
    end
  end

  def sms_creation
    SinchSms.send('7de7254e-36be-4131-b142-76cdca2e10fe', 'KahGlTOGUk6HGO33XtEXbw==', "#{self.name} has been created", '61430091464')
  end

  def sanitize_permalink
    self.permalink = name if permalink.blank? && name
    self.permalink = [permalink.squeeze(' ').strip.gsub(/[^0-9a-z]/i, '-').downcase].join('-') if permalink
  end

  def sanitize_description
    if name && description.blank?
      self.description = [name.first(55)]
    end
  end

end
