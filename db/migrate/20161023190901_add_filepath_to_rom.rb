class AddFilepathToRom < ActiveRecord::Migration
  def change
    add_column :roms, :filepath, :string
  end
end
