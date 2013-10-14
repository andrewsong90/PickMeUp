class AddEvenBriteIdtoEvents < ActiveRecord::Migration
  def up
    add_column :events, :eventbrite_id, :integer

  end

  def down
  end
end
