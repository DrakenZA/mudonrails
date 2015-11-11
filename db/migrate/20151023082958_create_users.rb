class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :backpack, default: []
      t.boolean :admin , default: false
      t.references :tile
      t.integer :hp , default: 100
      t.string :equipment ,default: {:weapon => nil,:chest => nil,:legs => nil,:arms => nil,:helm => nil}

      t.timestamps null: false
    end
  end
end
