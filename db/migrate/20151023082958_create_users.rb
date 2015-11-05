class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :backpack
      t.boolean :admin , default: false
      t.references :tile

      t.timestamps null: false
    end
  end
end
