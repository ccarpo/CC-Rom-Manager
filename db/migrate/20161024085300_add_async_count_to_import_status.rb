class AddAsyncCountToImportStatus < ActiveRecord::Migration
  def change
    add_column :import_statuses, :asyncCount, :integer
  end
end
