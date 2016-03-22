class AddAttachmentBackcoverToRoms < ActiveRecord::Migration
  def self.up
    change_table :roms do |t|
      t.attachment :backcover
    end
  end

  def self.down
    remove_attachment :roms, :backcover
  end
end
