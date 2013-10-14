class ChangeDateTimeFormatInEventsTable < ActiveRecord::Migration
  def up
    change_column :events, :DateTime, :string
    change_column :pmus, :datetime, :string
  end

  def down
    change_column :events, :DateTime, :datetime
    change_column :pmus, :datetime, :datetime
  end
end
