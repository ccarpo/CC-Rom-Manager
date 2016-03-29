class ImportStatus < ActiveRecord::Base

  def self.updateStatus(statusId, updateType)
    updatedStatus = ImportStatus.find(statusId)
    if updateType == "delete"
      updatedStatus.deleteCount += 1
    elsif updateType == "ignore"
      updatedStatus.ignoreCount += 1
    elsif updateType == "scrape"
      updatedStatus.scrapeCount += 1
    else
      logger.debug("unknown update status type")
    end

    if (updatedStatus.ignoreCount + updatedStatus.scrapeCount) == updatedStatus.totalCount
      updatedStatus.status = "FINISHED"
      updatedStatus.endtime = Time.now
    end
    updatedStatus.save
  end
end
