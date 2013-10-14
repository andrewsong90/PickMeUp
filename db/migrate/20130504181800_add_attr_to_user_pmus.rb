class AddAttrToUserPmus < ActiveRecord::Migration
  def up
    add_column :user_pmus, :location, :string
    add_column :user_pmus, :latitude, :float
    add_column :user_pmus, :longitude, :float
  end

  def down
    remove_column :user_pmus, :location
    remove_column :user_pmus, :latitude
    remove_column :user_pmus, :longitude
  end
end
