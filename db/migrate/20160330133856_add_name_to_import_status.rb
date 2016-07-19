class AddNameToImportStatus < ActiveRecord::Migration
  def change
    add_column :import_statuses, :name, :string
  end
end
