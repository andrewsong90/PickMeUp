class EventFilePickerAttr < ActiveRecord::Migration
  def up
    add_column :events, :filepicker_url, :string
  end

  def down
    remove_column :events, :filepicker_url
  end
end
