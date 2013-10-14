class AddEventIdColumnToPmus < ActiveRecord::Migration
  def change
    add_column :pmus, :event_id, :integer
  end
end
