#encoding utf-8
#coding utf-8

require 'dmm_scraping'

class Tasks::ScrapingBatchRunner
  def self.execute(methodName)
    dmmScraping = DmmScraping.new()
    dmmScraping.send(methodName)
  end
end
