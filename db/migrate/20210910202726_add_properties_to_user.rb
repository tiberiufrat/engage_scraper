class AddPropertiesToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :first_name, :string
  	add_column :users, :last_name, :string
  	add_column :users, :phone, :string
  	add_column :users, :gender, :string
		add_column :users, :house, :string
		add_column :users, :year, :integer
  	add_column :users, :birth_date, :date
	  add_column :users, :locale, :string, default: :ro
    add_column :users, :active, :boolean, null: false, default: true

		add_column :users, :image, :string

		add_column :users, :last_synced, :datetime

		add_column :users, :parent_name, :string
		add_column :users, :parent_email, :string
		add_column :users, :parent_phone, :string

  	add_reference :users, :form, foreign_key: { to_table: :forms }
  end
end
