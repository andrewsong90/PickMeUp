class FixEventColName < ActiveRecord::Migration
  def up
    rename_column :events, :adress, :address
  end

  def down
    rename_column :events, :adress, :address
  end
end
