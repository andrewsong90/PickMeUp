class AddEmailGenderPhoneToUser < ActiveRecord::Migration
  def change
    add_column :users, :email, :string
    add_column :users, :gender, :string
    add_column :users, :phone, :integer
  end
end
