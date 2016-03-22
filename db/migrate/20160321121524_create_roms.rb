class CreateRoms < ActiveRecord::Migration
  def change
    create_table :roms do |t|
      t.string :title
      t.text :description
      t.string :publisher
      t.integer :rating
      t.integer :players
      t.date :releasedate
      t.string :developer
      t.binary :frontcover
      t.binary :backcover

      t.timestamps null: false
    end
  end
end
