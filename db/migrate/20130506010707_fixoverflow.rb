class Fixoverflow < ActiveRecord::Migration
  def up
    change_column :events, :eventbrite_id, :string
  end

  def down
  end
end
