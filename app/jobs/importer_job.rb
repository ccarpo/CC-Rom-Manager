class ImporterJob
  include SuckerPunch::Job
  include HTTParty

  workers 4

  def perform(title, console, filename, statusId)
    logger.debug('-----------scrape '+title+'-------------------')
    if ImporterController::GAME_LIST[console[0]] == nil || ImporterController::GAME_LIST[console[0]] == []
      logger.debug('Download game list for '+console[0])
      ImporterController::GAME_LIST[console[0]] = HTTParty.get(ImporterController::BASE_API_URL+'GetPlatformGames.php?platform='+console[2].to_s)
    end
    game = findGameInGameList(title, ImporterController::GAME_LIST[console[0]])

    newRom = Rom.new
    newRom.filename = filename
    newRom.console = console[0]
    newRom.title = title

    if game != nil
      # Cover
      baseImgUrl = game['Data']['baseImgUrl']
      if game['Data']['Game']['Images']['boxart'].kind_of?(Array)
        for boxart in game['Data']['Game']['Images']['boxart']
          getBoxart(boxart, baseImgUrl, newRom)
        end
      else
          getBoxart(game['Data']['Game']['Images']['boxart'], baseImgUrl, newRom)
      end

      #Metadata
      newRom.releasedate = game['Data']['Game']['ReleaseDate']
      newRom.description = game['Data']['Game']['Overview']
      newRom.players = game['Data']['Game']['Players']
      newRom.publisher = game['Data']['Game']['Publisher']
      newRom.developer = game['Data']['Game']['Developer']

      newRom.save

      if game['Data']['Game']['Genres'] != nil
        if game['Data']['Game']['Genres']['genre'].kind_of?(Array)
          for genre in game['Data']['Game']['Genres']['genre']
            newRom.genres.create(name: genre.to_s)
          end
        else
          newRom.genres.create(name: genre.to_s)
        end
      end
      newRom.save
    end
    ImportStatus.updateStatus(statusId, "scrape")

  end

private
  def findGameInGameList(title, gameList)
    for game in gameList['Data']['Game']
      if game['GameTitle'] == title
        logger.debug('http://thegamesdb.net/api/GetGame.php?id='+game['id'])
        return HTTParty.get('http://thegamesdb.net/api/GetGame.php?id='+game['id'])
      end
    end
    return nil
  end

  def getBoxart(boxart, baseImgUrl, newRom)
    logger.debug(boxart.to_s)
    if boxart['side'] == 'front'
      newRom.frontcoverlink = baseImgUrl+boxart['__content__']
    elsif boxart['side'] == 'back'
      newRom.backcoverlink = baseImgUrl+boxart['__content__']
    end
  end

end
