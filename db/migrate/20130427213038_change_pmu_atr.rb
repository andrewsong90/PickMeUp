class ChangePmuAtr < ActiveRecord::Migration
  def change
    rename_column :pmus, :owner, :owner_id
  end
end
