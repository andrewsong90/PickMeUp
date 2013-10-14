class MoreEventAttr < ActiveRecord::Migration
  def up
    add_column :events, :genre, :string
  end

  def down
    remove_column :events, :genre
  end
end
