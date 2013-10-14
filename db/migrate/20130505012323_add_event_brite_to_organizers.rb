class AddEventBriteToOrganizers < ActiveRecord::Migration
  def change
    add_column :organizers, :eventbrite_id, :integer
  end
end
