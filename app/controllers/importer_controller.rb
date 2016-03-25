class ImporterController < ApplicationController

include HTTParty
require 'net/http'

BASE_API_URL = 'http://thegamesdb.net/api/'

  def index
  end

  def importAll
    config = SimpleConfig.for(:application)
    #import nes
    @nesRomCount, @nesImportedRomCount, @nesDeletedCount = importByConsole(Console::NES, config.nes.romPath, 'nes')
    #import snes
    @snesRomCount, @snesImportedRomCount, @snesDeletedCount = importByConsole(Console::SNES, config.snes.romPath, 'zip')
    #import gb(c)
    @gbcRomCount, @gbcImportedRomCount, @gbcDeletedCount = importByConsole('gbc', config.gbc.romPath, 'zip')
    #import gba
    @gbaRomCount, @gbaImportedRomCount, @gbaDeletedCount = importByConsole('gba', config.gba.romPath, 'zip')
    #import n64
    @n64RomCount, @n64ImportedRomCount, @n64DeletedCount = importByConsole('n64', config.n64.romPath, 'zip')
    #import sega
    @segaRomCount, @segaImportedRomCount, @segaDeletedCount = importByConsole('sega', config.sega.romPath, 'zip')
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

        #create rom
        newRom = Rom.new
        newRom.filename = filename
        newRom.console = console[0]
        newRom.title = title

        #scrapeRom
        scrape(title, console, newRom)


        newRom.save
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

  def scrapeTitle()
    title = "Devil World"
    newRom = Rom.new
    newRom.filename = "Devil World (Europe).nes"
    newRom.console = Console::NES[0]
    newRom.title = title
    scrape(title, Console::NES, newRom)
    newRom.save
    render 'import'
  end

  def scrape(title, console, newRom)
    logger.debug('-----------scrape '+title+'-------------------')
    logger.debug(BASE_API_URL+'GetGamesList.php?name='+title+'&platform='+console[1])
    games = HTTParty.get(BASE_API_URL+'GetGamesList.php?name='+title+'&platform='+console[1])
    logger.debug(games)
    if games['Data'] != nil
      gameTitle = games['Data']['Game'][0]['GameTitle']
      logger.debug(gameTitle)
      if title == gameTitle
        id = games['Data']['Game'][0]['id']
        logger.debug(BASE_API_URL+'GetGame.php?id='+id)
        game = HTTParty.get(BASE_API_URL+'GetGame.php?id='+id)
        logger.debug(game)

        # Cover
        baseImgUrl = game['Data']['baseImgUrl']
        for boxart in game['Data']['Game']['Images']['boxart']
          if boxart['side'] = 'front'
            logger.debug(baseImgUrl+boxart['__content__'])
            url = URI.parse(baseImgUrl+boxart['__content__'])
            Net::HTTP.start(url.host, url.port) do |http|
              resp, data = http.get(url.path, nil)
              #newRom.frontcover = resp.body
            end
          elsif boxart['side'] = 'back'
            url = URI.parse(baseImgUrl+boxart['__content__'])
            Net::HTTP.start(url.host, url.port) do |http|
              resp, data = http.get(url.path, nil)
              #newRom.backcover = resp.body
            end
          end
        end

        #Metadata
        newRom.releasedate = game['Data']['Game']['ReleaseDate']
        newRom.description = game['Data']['Game']['Overview']
        newRom.players = game['Data']['Game']['Players']
        newRom.publisher = game['Data']['Game']['Publisher']
        newRom.developer = game['Data']['Game']['Developer']

        #TODO: implement genres
        if game['Data']['Game']['Genres']['genre'].kind_of?(Array)
          for genre in game['Data']['Game']['Genres']['genre']
            logger.debug(genre)
          end
        else
          logger.debug(game['Data']['Game']['Genres']['genre'])
        end
      end
    end
  end

end

module Console
  NES = ['nes', 'Nintendo Entertainment System (NES)']
  SNES = ['snes', 'Super Nintendo (SNES)']
  N64 = ['n64', 'Nintendo 64']
  GBA = ['gba', 'Nintendo Game Boy Advance']
  GB = ['gbc', 'Nintendo Game Boy']
  GBC = ['gbc', 'Nintendo Game Boy Color']
  SMD = ['smd', 'Sega Mega Drive']
  SMS = ['sms', 'Sega Master System']
end
