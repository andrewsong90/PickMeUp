class TicketAttr < ActiveRecord::Migration
  def up
    add_column :tickets, :owner_id, :integer, :default => -1
  end

  def down
    remove_column :tickets, :owner_id
  end
end
