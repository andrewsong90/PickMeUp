class AddCodeColumnToUserPmus < ActiveRecord::Migration
  def change
    add_column :user_pmus, :code, :string
  end
end
