class CreateTiles < ActiveRecord::Migration
  def change
    create_table :tiles do |t|
      t.integer :xcoord
      t.integer :ycoord
      t.integer :tiletype
      t.string :desc
      t.string :exits ,default: {}
      t.string :backpack , default: []

      t.timestamps null: false
    end
  end
end
