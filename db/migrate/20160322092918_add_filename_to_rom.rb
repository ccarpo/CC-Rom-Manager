class AddFilenameToRom < ActiveRecord::Migration
  def change
    add_column :roms, :filename, :string
  end
end
