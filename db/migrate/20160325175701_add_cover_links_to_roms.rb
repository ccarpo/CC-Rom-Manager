class AddCoverLinksToRoms < ActiveRecord::Migration
  def change
    add_column :roms, :frontcoverlink, :string
    add_column :roms, :backcoverlink, :string
  end
end
