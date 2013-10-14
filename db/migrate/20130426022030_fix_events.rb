class FixEvents < ActiveRecord::Migration
  def up
    remove_column :tickets, :name
  end

  def down
  end
end
