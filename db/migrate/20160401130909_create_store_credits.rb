class CreateStoreCredits < ActiveRecord::Migration
  def change
    create_table :store_credits do |t|
      t.decimal :amount, default: 0.0, precision: 8, scale: 2
      t.integer :user_id, null: false
      t.datetime :expire_at, default: Date.today + 6.months
      t.datetime :last_expired_at, null: true
      t.timestamps null: false
    end

    add_index :store_credits, :user_id

  end
end
