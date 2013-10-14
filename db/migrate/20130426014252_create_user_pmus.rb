class CreateUserPmus < ActiveRecord::Migration
  def change
    create_table :user_pmus do |t|
      t.integer :user_id
      t.integer :pmu_id

      t.timestamps
      
      t.references :user
      t.references :pmu
    end
  end
end
