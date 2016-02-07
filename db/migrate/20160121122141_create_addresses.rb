class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.integer :address_type_id
      t.string :first_name
      t.string :last_name
      t.string :addressable_type
      t.integer :addressable_id
      t.string :address1
      t.string :address2
      t.string :city
      t.integer :state_id
      t.string :state_name
      t.string :zip_code
      t.integer :phone_id
      t.string :alternative_phone
      t.boolean :default
      t.boolean :billing_default
      t.boolean :active
      t.integer :country_id

      t.timestamps null: false
    end

    add_index "addresses", ["addressable_id"], name: "index_addresses_on_addressable_id", using: :btree
    add_index "addresses", ["addressable_type"], name: "index_addresses_on_addressable_type", using: :btree
    add_index "addresses", ["state_id"], name: "index_addresses_on_state_id", using: :btree

  end
end