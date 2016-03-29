class AddCountsToImportStatus < ActiveRecord::Migration
  def change
    add_column :import_statuses, :totalCount, :integer
    add_column :import_statuses, :ignoreCount, :integer
  end
end
