class AddConfirmedColumnToUserPmus < ActiveRecord::Migration
  def change
    add_column :user_pmus, :confirmed, :boolean
  end
end
