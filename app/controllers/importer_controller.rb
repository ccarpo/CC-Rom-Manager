class ImporterController < ApplicationController

include HTTParty

BASE_API_URL = 'http://thegamesdb.net/api/'
GAME_LIST = {}

  def importAll
    @importStatusId = {}
    config = SimpleConfig.for(:application)

    #import nes
    importByConsole(Console::NES, config.nes.romPath, 'nes')
    #import snes
    importByConsole(Console::SNES, config.snes.romPath, 'zip')
    #import gb(c)
    importByConsole(Console::GB, config.gbc.romPath, 'zip')
    #import gba
    importByConsole(Console::GBA, config.gba.romPath, 'zip')
    #import n64
    importByConsole(Console::N64, config.n64.romPath, 'zip')
    #import sega
    importByConsole(Console::SMS, config.sega.romPath, 'sms')
    render 'index'
  end

  def importByConsole(console, folder, fileExtension)
    logger.debug("-------------------"+console[0]+"---------------------")

    importTime = Time.now
    logger.debug(folder)
    files = Dir[folder+"/*."+fileExtension]
    logger.debug(files.to_s)
    consoleRoms = Rom.where("console LIKE \""+console[0]+"\" ")
    @romCount = consoleRoms.count
    deletedCount = 0

    #create importstatus to track import
    status = ImportStatus.new
    status.starttime = importTime
    status.console = console[0]
    status.totalCount = files.count
    status.scrapeCount = 0
    status.ignoreCount = 0
    status.deleteCount = 0
    status.status = "IMPORTING"
    status.save
    @importStatusId[console[0]] = status.id

    for file in files
      # get title from file named
      filename = file.gsub(/.*\//, '')
      title = filename.gsub(/([\w\d\s\-\&\.\,\!\'\+]*)(\(.*\))*\.\w\w\w?$/,'\1').strip
      if title != nil
        romFound = Rom.where("filename LIKE \""+filename+"\" and console LIKE \""+console[0]+"\" ").first
        #check if rom is already in DB
        if romFound == nil
          logger.debug("New Entry: "+title)

            #scrapeRom
          ImporterJob.perform_async(title, Console::NES, filename, status.id)
        else
          logger.debug("Update Entry: " + romFound.filename)
          romFound.updated_at = importTime
          romFound.save
          updateStatus(status.id, "ignore")
        end
      else
        #title could not be parsed
        ImportStatus.updateStatus(status.id, "ignore")
      end
    end

    for rom in consoleRoms
      if rom.updated_at < importTime
        #not updated, not in folder anymore, delete
        rom.destroy
        ImportStatus.updateStatus(status.id, "delete")
      end
    end
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
    render 'importStatus/'+status.id
  end

  def deleteStatus
    logger.debug("------------delete status "+params[:id]+"-------------")
    status = ImportStatus.find(params[:id])
    status.destroy
    render '/importer/index'
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
