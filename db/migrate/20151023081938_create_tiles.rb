class CreateTiles < ActiveRecord::Migration
  def change
    create_table :tiles do |t|
      t.integer :xcoord
      t.integer :ycoord
      t.integer :tiletype
      t.string :desc
      t.string :exits

      t.timestamps null: false
    end
  end
end
