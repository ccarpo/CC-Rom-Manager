class CreateImportGames < ActiveRecord::Migration
  def change
    create_table :import_games do |t|
      t.string :status
      t.string :gameId
      t.integer :importStatusId

      t.timestamps null: false
    end
  end
end
