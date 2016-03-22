class AddTypeToRom < ActiveRecord::Migration
  def change
    add_column :roms, :type, :string
  end
end
