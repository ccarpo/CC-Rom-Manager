class CreateImportStatuses < ActiveRecord::Migration
  def change
    create_table :import_statuses do |t|
      t.datetime :starttime
      t.datetime :endtime
      t.integer :deleteCount
      t.integer :scrapeCount
      t.string :status

      t.timestamps null: false
    end
  end
end
