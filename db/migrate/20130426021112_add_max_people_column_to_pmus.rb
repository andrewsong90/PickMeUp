class AddMaxPeopleColumnToPmus < ActiveRecord::Migration
  def change
    add_column :pmus, :max_people, :integer
  end
end
