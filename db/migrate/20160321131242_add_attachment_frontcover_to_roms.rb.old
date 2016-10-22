class AddAttachmentFrontcoverToRoms < ActiveRecord::Migration
  def self.up
    change_table :roms do |t|
      t.attachment :frontcover
    end
  end

  def self.down
    remove_attachment :roms, :frontcover
  end
end
