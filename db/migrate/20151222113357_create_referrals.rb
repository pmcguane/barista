class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.boolean :applied
      t.datetime :clicked_at
      t.string :email
      t.string :name
      t.datetime :purchased_at
      t.integer :referral_program_id
      t.integer :referral_type_id
      t.integer :referral_user_id
      t.integer :referring_user_id
      t.datetime :registered_at
      t.datetime :sent_at

      t.timestamps null: false
    end
  end
end
