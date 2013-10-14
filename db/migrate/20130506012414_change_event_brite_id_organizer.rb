class ChangeEventBriteIdOrganizer < ActiveRecord::Migration
  def change
    change_column :organizers, :eventbrite_id, :string
  end
end
