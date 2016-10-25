class ImporterController < ApplicationController

include HTTParty

BASE_API_URL = 'http://thegamesdb.net/api/'
GAME_LIST = {}
CONSOLES = {
  "NES" => {id: 'nes', name: 'Nintendo Entertainment System (NES)', thegamesdbId: 7, romPath: SimpleConfig.for(:application).nes.romPath, fileExtension: SimpleConfig.for(:application).nes.fileExtension},
  "SNES"=> {id: 'snes', name: 'Super Nintendo (SNES)', thegamesdbId: 6, romPath: SimpleConfig.for(:application).snes.romPath, fileExtension: SimpleConfig.for(:application).snes.fileExtension},
  "N64" => {id: 'n64', name: 'Nintendo 64', thegamesdbId: 3, romPath: SimpleConfig.for(:application).n64.romPath, fileExtension: SimpleConfig.for(:application).n64.fileExtension},
  "GBA" => {id: 'gba', name: 'Nintendo Game Boy Advance', thegamesdbId: 5, romPath: SimpleConfig.for(:application).gba.romPath, fileExtension: SimpleConfig.for(:application).gba.fileExtension},
  "GB"  =>  {id: 'gb', name: 'Nintendo Game Boy', thegamesdbId: 4, romPath: SimpleConfig.for(:application).gb.romPath, fileExtension: SimpleConfig.for(:application).gb.fileExtension},
  "GBC" => {id: 'gbc', name: 'Nintendo Game Boy Color', thegamesdbId: 41, romPath: SimpleConfig.for(:application).gbc.romPath, fileExtension: SimpleConfig.for(:application).gbc.fileExtension},
  "SMD" => {id: 'smd', name: 'Sega Mega Drive', thegamesdbId: 36, romPath: SimpleConfig.for(:application).segadrive.romPath, fileExtension: SimpleConfig.for(:application).segadrive.fileExtension},
  "SMS" => {id: 'sms', name: 'Sega Master System', thegamesdbId: 35, romPath: SimpleConfig.for(:application).segasystem.romPath, fileExtension: SimpleConfig.for(:application).segasystem.fileExtension}
  "SCUMM"  => {id: 'scumm', name: 'SCUMM Spiele', thegamesdbId: 1, romPath: SimpleConfig.for(:application).scumm.romPath, fileExtension: SimpleConfig.for(:application).scumm.fileExtension}
}

  def importAll
    @importStatusId = {}
    config = SimpleConfig.for(:application)

    CONSOLES.each{ |name, console|
      logger.debug("Start importing "+ console[:id].to_s)
        importByConsole(console)
      }
    redirect_to '/importer'
  end

  def importConsole
    @importStatusId = {}
    config = SimpleConfig.for(:application)
    logger.debug(params[:console])

    rightConsole = CONSOLES[params[:console]]
    #import nes
    importByConsole(rightConsole)

    redirect_to '/importer'
  end


  def importByConsole(console)
    logger.debug("-------------------"+console[:id]+"---------------------")
    logger.debug(SimpleConfig.for(:application).common.filesystemRoot+console[:romPath]+"/*."+console[:fileExtension])
    importTime = Time.now
    files = Dir[SimpleConfig.for(:application).common.filesystemRoot+console[:romPath]+"/*."+console[:fileExtension]]
    logger.debug(files.to_s)
    consoleRoms = Rom.where("console LIKE \""+console[:id]+"\" ")
    logger.debug(consoleRoms.to_s)
    @romCount = consoleRoms.count
    deletedCount = 0

    #create importstatus to track import
    status = ImportStatus.new
    status.starttime = importTime
    status.console = console[:id]
    status.totalCount = files.count
    status.scrapeCount = 0
    status.ignoreCount = 0
    status.deleteCount = 0
    status.status = "IMPORTING"
    status.save
    @importStatusId[console[:id]] = status.id

    fCounter = 0
    for file in files
      fCounter += 1
      logger.debug("============"+fCounter.to_s+"============")
      # get title from file named
      filename = file.gsub(/.*\//, '')
      title = filename.gsub(/([\w\d\s\-\&\.\,\!\'\+]*)(\(.*\))*\.\w\w\w?$/,'\1').strip
      if title != nil
        romFound = Rom.where("filename LIKE \""+filename+"\" and console LIKE \""+console[:id]+"\" ").first
        #check if rom is already in DB
        if romFound == nil
          logger.debug("New Entry: "+title)
          status.asyncCount += 1
          status.save
          ImporterJob.perform_async(title, console, console[:romPath], filename, status.id)

        else
          logger.debug("Update Entry: " + romFound.filename)
          romFound.updated_at = importTime
          romFound.save
          ImportStatus.updateStatus(status.id, "ignore")
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

  def deleteStatus
    logger.debug("------------delete status "+params[:id]+"-------------")
    status = ImportStatus.find(params[:id])
    status.destroy
    redirect_to '/importer'
  end

end
