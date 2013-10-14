class AddEventIdToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :event_id, :integer
  end
end
