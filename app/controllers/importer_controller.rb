class ImporterController < ApplicationController
  def index
  end

  def import
    files = Dir["D:/projects/garbage/rails/ccrm/public/nesroms/*.nes"]
    @romCount = Rom.all.count
    @importedCount = 0
    for file in files
      # get title from file named
      filename = file.gsub(/.*\//, '')
      title = filename[/[\w\d\s\-\&\.\,\!\'\+]*/].strip
      romFound = Rom.select("title").where("title LIKE \""+title+"\"").first
      logger.debug("!"+romFound.to_s+"!")
      #check if rom is already in DB
      if romFound == nil
        logger.debug("New Entry")
        #create rom
        newRom = Rom.new
        newRom.title = title
        newRom.filename = filename
        newRom.save
        @importedCount += 1
      end
    end
  end

end
