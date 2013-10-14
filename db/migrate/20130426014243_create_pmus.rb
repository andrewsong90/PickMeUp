class CreatePmus < ActiveRecord::Migration
  def change
    create_table :pmus do |t|
      t.integer :owner
      t.datetime :datetime
      t.string :location
      t.float :latitude
      t.float :longitude
      t.string :type
      t.boolean :cab_sharing
      t.boolean :car_sharing

      t.references :user
      t.timestamps
    end
  end
end
