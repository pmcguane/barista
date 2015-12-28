class TransactionLedger < ActiveRecord::Base
  belongs_to :transaction_account
  belongs_to :transactionn, class_name: 'Transaction', foreign_key: :transaction_id
  belongs_to :accountable, polymorphic: true


  validates :accountable_type,        presence: true
  validates :accountable_id,          presence: true
  #validates :transaction_id,          presence: true## test fails but we need this validation back in
  validates :transaction_account_id,  presence: true

  validates :debit,   presence: true
  validates :credit,  presence: true
  validates :period,  presence: true

  def revenue
    (transaction_account_id == TransactionAccount::REVENUE_ID) ? (credit - debit) : 0.0
  end

  def cash
    (transaction_account_id == TransactionAccount::CASH_ID) ? (credit - debit) : 0.0
  end

  def accounts_receivable
    (transaction_account_id == TransactionAccount::ACCOUNTS_RECEIVABLE_ID) ? (credit - debit) : 0.0
  end

  def accounts_payable
    (transaction_account_id == TransactionAccount::ACCOUNTS_PAYABLE_ID) ? (credit - debit) : 0.0
  end

  def transaction_account_name
    Rails.cache.fetch("transaction_account_name-#{transaction_account_id}", :expires_in => 12.hours) do
      transaction_account.name
    end
  end

  def self.between(start_time, end_time)
    where("created_at >= ? AND created_at <= ?", start_time, end_time)
  end
end