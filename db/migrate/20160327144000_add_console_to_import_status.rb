class AddConsoleToImportStatus < ActiveRecord::Migration
  def change
    add_column :import_statuses, :console, :string
  end
end
