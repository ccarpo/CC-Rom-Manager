class ImporterController < ApplicationController

include HTTParty

BASE_API_URL = 'http://thegamesdb.net/api/'
GAME_LIST = {'nes' => nil, 'snes' => nil}

  def index
  end

  def importAll
    config = SimpleConfig.for(:application)
    #import nes
    @nesRomCount, @nesImportedRomCount, @nesDeletedCount = importByConsole(Console::NES, config.nes.romPath, 'nes')
    #import snes
    @snesRomCount, @snesImportedRomCount, @snesDeletedCount = importByConsole(Console::SNES, config.snes.romPath, 'zip')
    #import gb(c)
    @gbcRomCount, @gbcImportedRomCount, @gbcDeletedCount = importByConsole(Console::GB, config.gbc.romPath, 'zip')
    #import gba
    @gbaRomCount, @gbaImportedRomCount, @gbaDeletedCount = importByConsole(Console::GBA, config.gba.romPath, 'zip')
    #import n64
    @n64RomCount, @n64ImportedRomCount, @n64DeletedCount = importByConsole(Console::N64, config.n64.romPath, 'zip')
    #import sega
    @segaRomCount, @segaImportedRomCount, @segaDeletedCount = importByConsole(Console::SMS, config.sega.romPath, 'zip')
    render 'import'
  end

  def importByConsole(console, folder, fileExtension)
    logger.debug("-------------------"+console[0]+"---------------------")
    importTime = Time.now
    logger.debug(folder)
    files = Dir[folder+"/*."+fileExtension]
    logger.debug(files.to_s)
    consoleRoms = Rom.where("console LIKE \""+console[0]+"\" ")
    romCount = consoleRoms.count
    importedCount, deletedCount = 0
    for file in files
      # get title from file named
      filename = file.gsub(/.*\//, '')
      title = filename.gsub(/([\w\d\s\-\&\.\,\!\'\+]*)(\(.*\))*\.\w\w\w?/,'\1').strip
      romFound = Rom.where("filename LIKE \""+filename+"\" and console LIKE \""+console[0]+"\" ").first
      #check if rom is already in DB
      if romFound == nil
        logger.debug("New Entry: "+title)

        #scrapeRom
        ImporterJob.perform_async(title, Console::NES, filename)

        importedCount += 1
      else
        logger.debug("Update Entry: " + romFound.filename)
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

#TODO: remove after test
  def scrapeTitle()
    title = "Devil World"
    newRom = Rom.new
    newRom.filename = "Devil World (Europe).nes"
    newRom.console = Console::NES[0]
    newRom.title = title
    ImporterJob.perform_async(title, Console::NES, newRom)
    newRom.save
    render 'import'
  end

  def scrape(title, console, newRom)

  end

end

module Console
  NES = ['nes', 'Nintendo Entertainment System (NES)', 7]
  SNES = ['snes', 'Super Nintendo (SNES)', 6]
  N64 = ['n64', 'Nintendo 64', 3]
  GBA = ['gba', 'Nintendo Game Boy Advance', 5]
  GB = ['gbc', 'Nintendo Game Boy', 4]
  GBC = ['gbc', 'Nintendo Game Boy Color', 41]
  SMD = ['smd', 'Sega Mega Drive', 36]
  SMS = ['sms', 'Sega Master System', 35]
end
