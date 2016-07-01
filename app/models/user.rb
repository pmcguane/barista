class User < ActiveRecord::Base
  include Clearance::User

  include AASM
  include UserCim
  include Presentation::UserPresenter
  include UserEmailer

  rolify

  before_validation :sanitize_data
  after_create :start_store_credits #, :subscribe_to_newsletters
  after_create  :set_referral_registered_at, :create_braintree_customer, :assign_user_role

  # belongs_to :account

  has_many  :referrals, class_name: 'Referral', foreign_key: 'referring_user_id' # people you have tried to referred
  has_one   :referree,  class_name: 'Referral', foreign_key: 'referral_user_id' # person who referred you

  has_one     :store_credit
  has_many    :orders
  # has_many    :comments
  # has_many    :customer_service_comments, as:         :commentable,
  #             class_name: 'Comment'
  has_many    :shipments, :through => :orders
  has_many    :finished_orders,           -> { where(state: ['complete', 'paid']) },  class_name: 'Order'
  has_many    :completed_orders,          -> { where(state: 'complete') },            class_name: 'Order'

  has_many    :phones,          dependent: :destroy,       as: :phoneable
  # has_one     :primary_phone, -> { where(primary: true) }, as: :phoneable, class_name: 'Phone'

  has_many    :addresses,       dependent: :destroy,       as: :addressable

  has_one     :default_billing_address,   -> { where(billing_default: true, active: true) },
              as:         :addressable,
              class_name: 'Address'

  has_many    :billing_addresses,         -> { where(active: true) },
              as:         :addressable,
              class_name: 'Address'

  has_one     :default_shipping_address,  -> { where(default: true, active: true) },
              as:         :addressable,
              class_name: 'Address'

  has_many     :shipping_addresses,       -> { where(active: true) },
               as:         :addressable,
               class_name: 'Address'

  has_many    :user_roles,                dependent: :destroy
  # has_many    :roles,                     through: :user_roles

  has_many    :carts,                     dependent: :destroy

  has_many    :cart_items
  has_many    :shopping_cart_items, -> { where(active: true, item_type_id: ItemType::SHOPPING_CART_ID) }, class_name: 'CartItem'
  has_many    :wish_list_items,     -> { where(active: true, item_type_id: ItemType::WISH_LIST_ID) },     class_name: 'CartItem'
  has_many    :saved_cart_items,    -> { where(active: true, item_type_id: ItemType::SAVE_FOR_LATER) },   class_name: 'CartItem'
  has_many    :purchased_items,     -> { where(active: true, item_type_id: ItemType::PURCHASED_ID) },     class_name: 'CartItem'
  has_many    :deleted_cart_items,  -> { where( active: false) }, class_name: 'CartItem'
  has_many :payment_methods


  # validates :first_name,  presence: true, if: :registered_user?,
  #           format:   { with: ::CustomValidators::Names.name_validator },
  #           length:   { maximum: 30 }
  # validates :last_name,   :presence => true, :if => :registered_user?,
  #           :format   => { :with => ::CustomValidators::Names.name_validator },
  #           :length => { :maximum => 35 }
  # validates :email,       :presence => true,
  #           :uniqueness => true,##  This should be done at the DB this is too expensive in rails
  #           :format   => { :with => ::CustomValidators::Emails.email_validator },
  #           :length => { :maximum => 255 }
  # validates :mobile,       :presence => true,
  #           :uniqueness => true,##  This should be done at the DB this is too expensive in rails
  #           :format   => { :with => ::CustomValidators::Numbers.phone_number_validator },
  #           :length => { :maximum => 10 }

  accepts_nested_attributes_for :addresses
  accepts_nested_attributes_for :phones, :reject_if => lambda { |t| ( t['display_number'].gsub(/\D+/, '').blank?) }
  # accepts_nested_attributes_for :customer_service_comments, :reject_if => proc { |attributes| attributes['note'].strip.blank? }

  aasm column: :state do
    state :inactive
    state :active, initial: true
    state :canceled

    event :activate do
      transitions from: [:inactive, :canceled], to: :active, unless: :active?
    end

    event :cancel do
      transitions from: [:inactive, :active, :canceled], to: :canceled
    end

  end

  # returns true or false if the user is active or not
  #
  # @param [none]
  # @return [ Boolean ]
  def active?
    !%w(canceled inactive).any? do |s|
      self.state == s
    end
  end

  # returns true or false if the user has a role or not
  #
  # @param [String] role name the user should have
  # @return [ Boolean ]
  def role?(role_name)
    roles.any? {|r| r.name == role_name.to_s}
  end

  # returns true or false if the user is an admin or not
  #
  # @param [none]
  # @return [ Boolean ]
  def staff?
    role?(:staff) || role?(:admin)
  end

  # returns true or false if the user is a super admin or not
  # FYI your IT staff might be an admin but your CTO and IT director is a super admin
  #
  # @param [none]
  # @return [ Boolean ]
  def admin?
    role?(:admin)
  end

  # returns true or false if the user is a registered user or not
  #
  # @param [none]
  # @return [ Boolean ]
  def registered_user?
    active?
  end

  # returns your last cart or nil
  #
  # @param [none]
  # @return [ Cart ]
  def current_cart
    carts.last
  end

  ##  This method will one day grow into the products a user most likely likes.
  #   Storing a list of product ids vs cron each night might be the most efficent mode for this method to work.
  def might_be_interested_in_these_products
    Product.limit(4)
  end

  # Returns the default billing address if it exists.   otherwise returns the shipping address
  #
  # @param [none]
  # @return [ Address ]
  def billing_address
    default_billing_address ? default_billing_address : shipping_address
  end

  # Returns the default shipping address if it exists.   otherwise returns the first shipping address
  #
  # @param [none]
  # @return [ Address ]
  def shipping_address
    default_shipping_address ? default_shipping_address : shipping_addresses.first
  end

  # name and first line of address (used by credit card gateway to descript the merchant)
  #
  # @param  [ none ]
  # @return [ String ] name and first line of address
  def merchant_description
    [name, default_shipping_address.try(:address_lines)].compact.join(', ')
  end

  # include addresses in Find
  #
  # @params [ none ]
  # @return [ Arel ]
  def include_default_addresses
    includes([:default_billing_address, :default_shipping_address, :account])
  end

  def number_of_finished_orders
    finished_orders.count
  end

  def number_of_finished_orders_at(at)
    finished_orders.select{|o| o.completed_at < at }.size
  end

  def store_credit_amount
    store_credit.amount
  end

  private

  class << self
    def one_month_reminder!
      StoreCredit.where("expire_at <= ?", Date.today.end_of_day + 3.months)
    end
    end


  def set_referral_registered_at
    if refer_al = Referral.find_by_email(email)
      refer_al.set_referral_user(id)
    end
  end

  def start_store_credits
    self.store_credit = StoreCredit.new(amount: 0.0, user: self)
    end

  def password_required?
    self.crypted_password.blank?
    end

  def subscribe_to_newsletters
    newsletter_ids = Newsletter.where(autosubscribe: true).pluck(:id)
    self.newsletter_ids = newsletter_ids
    end

  # sanitizes the saving of data.  removes white space and assigns a free account type if one doesn't exist
  #
  # @param  [ none ]
  # @return [ none ]
  def sanitize_data
    self.email = self.email.strip.downcase unless email.blank?
    self.first_name = self.first_name.strip.capitalize unless first_name.nil?
    self.last_name = self.last_name.strip.capitalize unless last_name.nil?

    ## CHANGE THIS IF YOU HAVE DIFFERENT ACCOUNT TYPES
    # self.account = Account.first unless account_id
    end

  def create_braintree_customer
    # self.access_token = SecureRandom::hex(9+rand(6)) if access_token.nil?
    result = Braintree::Customer.create(
        :first_name => self.first_name,
        :last_name => self.last_name,
        :email => self.email,
        :phone => self.mobile,
        :payment_method_nonce => 'fake-valid-nonce'
    )
    if result.success?
      puts result.customer.id
      puts result.customer.payment_methods[0].token
      update_column(:customer_cim_id, result.customer.id)
    else
      p result.errors
    end
  end

  def assign_user_role
    # self.add_role(:customer)
  end

end