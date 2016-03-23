class AddTypeToRom < ActiveRecord::Migration
  def change
    add_column :roms, :console, :string
  end
end
