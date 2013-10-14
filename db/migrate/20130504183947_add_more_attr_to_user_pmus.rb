class AddMoreAttrToUserPmus < ActiveRecord::Migration
  def up
    add_column :user_pmus, :datetime, :string
  end

  def down
    remove_column :user_pmus, :datetime
  end
end
