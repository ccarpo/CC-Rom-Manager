class ImporterController < ApplicationController

  def index
  end

  def importAll
    config = SimpleConfig.for(:application)
    logger.debug(config.my_variable.to_s)

    #import nes
    @nesRomCount, @nesImportedRomCount, @nesDeletedCount = importByType('nes', 'D:/projects/garbage/rails/ccrm/public/nesroms', 'nes')
    #import snes
    @snesRomCount, @snesImportedRomCount, @snesDeletedCount = importByType('snes', 'D:/projects/garbage/rails/ccrm/public/snesroms', 'zip')
    #import gb(c)
    @gbcRomCount, @gbcImportedRomCount, @gbcDeletedCount = importByType('gbc', 'D:/projects/garbage/rails/ccrm/public/gbcroms', 'zip')
    #import gba
    @gbaRomCount, @gbaImportedRomCount, @gbaDeletedCount = importByType('gba', 'D:/projects/garbage/rails/ccrm/public/gbaroms', 'zip')
    #import n64
    @n64RomCount, @n64ImportedRomCount, @n64DeletedCount = importByType('n64', 'D:/projects/garbage/rails/ccrm/public/n64roms', 'zip')
    #import sega
    @segaRomCount, @segaImportedRomCount, @segaDeletedCount = importByType('sega', 'D:/projects/garbage/rails/ccrm/public/segaroms', 'zip')
    render 'import'
  end

  def importByType(type, folder, fileExtension)
    logger.debug("-------------------"+type+"---------------------")
    importTime = Time.now
    logger.debug(folder)
    files = Dir[folder+"/*."+fileExtension]
    logger.debug(files.to_s)
    consoleRoms = Rom.where("console LIKE \""+type+"\" ")
    romCount = consoleRoms.count
    importedCount, deletedCount = 0
    for file in files
      # get title from file named
      filename = file.gsub(/.*\//, '')
      title = filename[/[\w\d\s\-\&\.\,\!\'\+]*/].strip
      romFound = Rom.select("filename").where("filename LIKE \""+filename+"\" and console LIKE \""+type+"\" ").first
      #check if rom is already in DB
      if romFound == nil
        logger.debug("New Entry: "+title)
        #create rom
        newRom = Rom.new
        newRom.title = title
        newRom.filename = filename
        newRom.console = type
        newRom.save
        importedCount += 1
      else
        logger.debug("Update Entry: " + romFound.title)
        romFound.updated_at = importTime
        romFound.save
      end
    end

    for rom in consoleRoms
      if rom.updated_at < importTime
        #not updated, not in folder anymore, delete
        deletedCount += 1
        rom.destroy
      end
    end

    return romCount, importedCount, deletedCount
  end
end
