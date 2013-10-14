class AddCompletedColumnToPmus < ActiveRecord::Migration
  def change
    add_column :pmus, :completed, :boolean
  end
end
