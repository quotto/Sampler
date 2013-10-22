#encoding ut-8
#coding utf-8
require 'bundler'
Bundler.require
require 'nokogiri'
require 'RMagick'
require 'date'
require 'open-uri'
require 'net/http'
require 'uri'
require './logutil.rb'
class Tasks::DMMScraping
  def initialize
    @page = 1
    @logfile = LogUtil.new("#{Rails.root}/log/scraping.log","#{Rails.root}/log/error.log")
  end
   def getPage(url)
    return Nokogiri::HTML(open(url).read)
  end
  
  def scraping
    res = getPage(url+"page=${@page}")
    res.css("#list li").each { |item|
      puts item.css("span.txt").text
    }
  end
  
  def self.execute(keyword)
    @keyword = keyword
    @url = "http://www.dmm.co.jp/search/=/searchstr=${@keyword}/n1=FgRCTw9VBA4GAVhfWkIHWw__/sort=ranking/view=/"
    @logfile.write("start scraping: keyword=${@keyword}")
    scraping()
  end
end