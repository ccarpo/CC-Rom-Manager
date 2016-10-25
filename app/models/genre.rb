class Genre < ActiveRecord::Base
  belongs_to :rom

  def self.genreString(genres)
    logger.debug("Blubb")
    genres_string = ""
    genres.each do |genre|
      if genres_string == ""
        genres_string = genre.name
      else
       genres_string = genres_string + ", " + genre.name
      end
    end
    logger.debug(genres_string)
    return genres_string
  end
end
