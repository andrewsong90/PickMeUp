class CreateOrganizers < ActiveRecord::Migration
  def change
    create_table :organizers do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :affiliation

      t.timestamps
    end
  end
end
