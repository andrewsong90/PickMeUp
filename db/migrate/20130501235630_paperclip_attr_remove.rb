class PaperclipAttrRemove < ActiveRecord::Migration
  def up
    remove_column :events, :photo_content_type
    remove_column :events, :photo_file_name
    remove_column :events, :photo_file_size
    remove_column :events, :photo_updated_at

  end

end
