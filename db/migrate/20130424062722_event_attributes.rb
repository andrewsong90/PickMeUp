class EventAttributes < ActiveRecord::Migration
  def up
    add_column :events, :name, :string
    add_column :events, :description, :text
    add_column :events, :DateTime, :datetime
  end

  def down
    remove_column :events, :name
    remove_column :events, :description
    remove_column :events, :DateTime
  end
end
