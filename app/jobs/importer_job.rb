class ImporterJob
  include SuckerPunch::Job
  include HTTParty

  workers 4

  def perform(title, console, filepath, filename, importStatus)
    logger.debug('-----------scrape '+title+'-------------------')
    if ImporterController::GAME_LIST[console[:id]] == nil || ImporterController::GAME_LIST[console[:id]] == []
      logger.debug('Download game list for '+console[:id])
      ImporterController::GAME_LIST[console[:id]] = HTTParty.get(ImporterController::BASE_API_URL+'GetPlatformGames.php?platform='+console[:thegamesdbId].to_s)
    end
    game = findGameInGameList(title, ImporterController::GAME_LIST[console[:id]])

    newRom = Rom.new
    newRom.filepath = filepath
    newRom.filename = filename
    newRom.console = console[:id]
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

      #newRom.save

      if game['Data']['Game']['Genres'] != nil
        if game['Data']['Game']['Genres']['genre'].kind_of?(Array)
          for genre in game['Data']['Game']['Genres']['genre']
            newRom.genres.create(name: genre.to_s)
          end
        else
          newRom.genres.create(name: genre.to_s)
        end
      end
    end
    newRom.save

    ImportStatus.reduceAsyncCount(statusId)
    ImportStatus.updateStatus(statusId, "scrape")

  end

private
  def findGameInGameList(title, gameList)
    for game in gameList['Data']['Game']
      if game['GameTitle'] == title
        logger.debug(ImportController::BASE_API_URL+'/GetGame.php?id='+game['id'])
        return HTTParty.get(ImportController::BASE_API_URL+'/GetGame.php?id='+game['id'])
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
