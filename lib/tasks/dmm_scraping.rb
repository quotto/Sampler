#encoding ut-8
#coding utf-8
require 'nokogiri'
require 'RMagick'
require 'date'
require 'open-uri'
require 'net/http'
require 'uri'
require 'cgi'
require 'movie.rb'
require 'tag.rb'
class DmmScraping
  private
  BITRATE_ID_300K = "sm_"
  BITRATE_ID_1000K = "dm_"
  BITRATE_ID_1500K = "dmb_"
  ASPECT_SINGLE_MARK = "s"
  ASPECT_WIDE_MARK = "w"
  MP4_HOSTNAME = "cc3001.dmm.co.jp/litevideo/freepv/"

  def initialize
    @page = 1
     @logger = Logger.new("#{Rails.root}/log/scraping.log",5,10 * 1024 * 1024)
  end
  
  def getPage(url)
    return Nokogiri::HTML(open(url).read)
  end

  def getCategory
    #ジャンル一覧を取得
    res = getPage("http://www.dmm.co.jp/litevideo/-/genre/")
    res_a = res.css("ul.d-boxcollist li a")
    return res_a
  end 
  
  def saveMovie(id,title,thumbnail,movie_url)
    movie_param = ActionController::Parameters.new(movie: {dmm_id: id, title: title, thumbnail: thumbnail,movie_url: movie_url})
    # newMovie = Movie.new(
    #   :dmm_id=>id,
    #   :title=>title,
    #   :thumbnail=>thumbnail,
    #   :movie_url=>movie_url
    #   )
    newMovie = Movie.new(movie_param[:movie].permit!)
    begin
      if newMovie.save
        @logger.info("Success insert movie id:#{id},title:#{title}")
      else
        @logger.warn("Not insert movie id:#{id},title:#{title}")
      end
    rescue ActiveRecord::RecordNotUnique => e
      @logger.error("Not insert movie(duplicate) id:#{id}")
    rescue => e
        @logger.error("Not insert movie(error) id:#{id} => #{e.inspect}")
    end
  end
  
  def saveTag(id,tag_name)    
    tag_param = ActionController::Parameters.new(tag: {dmm_id: id, tag_name: tag_name})
    newTag = Tag.new(tag_param[:tag].permit!)
    # newTag = Tag.new(
    #   :dmm_id=>id,
    #   :tag_name=>tag_name
    #   )
    begin
      if newTag.save
        @logger.info("Success insert tag id:#{id},tag:#{tag_name}")
      else
        @logger.warn("Not insert tag(duplicate) id:#{id},tag:#{tag_name}")
      end
    rescue => e
        @logger.error("Not insert tag(error) id:#{id},tag:#{tag_name} => #{e.inspect}")
    end
  end
  
  def scraping
    res = getPage(@url+"page=#{@page}")
    res.css("#list li").each { |item|
      div_tmb = item.css("p.tmb")
      thumbnail_url = div_tmb.css("img").attribute("src").value
      link_url = div_tmb.css("a").attribute("href").value
      start_index = link_url.index("cid=")
      id = link_url.slice((start_index+4)..(link_url.length-2))

      begin
        #リンク先からタイトルを取得する
        purl = URI.parse("http://www.dmm.co.jp/litevideo/-/detail/=/cid=#{id}/");	
        req = Net::HTTP::Get.new(purl.path)
        response = Net::HTTP.start(purl.host,purl.port) { |http|
          http.request(req);
        }
        res_link = Nokogiri::HTML(response.body)
        title = res_link.css("#page > h1 > span").text

        #動画ファイルのURL生成
        #objectタグのflashvarsパラメータ取得
        /flashvars.fid = "(.+)"/ =~ res_link.css("body").text
        fid = $1
        /flashvars.bid = "(.+)"/ =~ res_link.css("body").text
        bid = $1

        showBitRate = bid[0,1]
        bitRate = BITRATE_ID_300K
        if ((showBitRate.to_i & 1) > 0)
          bitRate = BITRATE_ID_300K
        end
        if ((showBitRate.to_i & 2) > 0)
          bitRate = BITRATE_ID_1000K
        end
        if ((showBitRate.to_i & 4) > 0)
          bitRate = BITRATE_ID_1500K
        end

        aspectMark = ""
        if (bid[1,1] == ASPECT_WIDE_MARK)
          aspectMark = ASPECT_WIDE_MARK
        else
          aspectMark = ASPECT_SINGLE_MARK
        end
        mp4_url = MP4_HOSTNAME + fid[0,1] + "/" + fid[0,3] + "/" + fid + "/" + fid + "_" + bitRate + aspectMark + ".mp4"

        saveMovie(id,title,thumbnail_url,mp4_url)

        #タグの取得
        tags = res_link.css("ul.tags > li span")
        tags.each{ |tag|
          tag_name = tag.text
          saveTag(id,tag_name)
        }
        #女優名を取得
        performers = res_link.css("#performer > a")
        performers.each{|performer|
          a_id = performer.attribute("id")
          if  a_id == nil 
            performer_name = performer.text
            saveTag(id,performer_name)
          end
        }
      rescue => e
        @logger.error("Error at #{id}:\n#{e}")
      end
    }
  end

  def executeByRank
    time = DateTime.now
		@logger.info(sprintf("[%d-%d-%d %d:%d:%d] start scraping(ByRank)",time.year,time.mon,time.mday,time.hour,time.min,time.sec))
    res_a = getCategory
    res_a.each{|a|
      #ジャンルごとのキーワードでスクレイピング開始（再生回数順）
      keyword =  a.text
      link =  a.attribute("href").value
      @logger.info("scraping: keyword=#{keyword}\n")
      @url = "http://www.dmm.co.jp#{link}/limit=60/sort=all_ranking/"
      scraping()
    }
    time = DateTime.now
    @logger.info(sprintf("[%d-%d-%d %d:%d:%d] end scraping(ByRank)",time.year,time.mon,time.mday,time.hour,time.min,time.sec))
  end
  
  def executeByDate
    time = DateTime.now
		@logger.info(sprintf("[%d-%d-%d %d:%d:%d] start scraping(ByDate)",time.year,time.mon,time.mday,time.hour,time.min,time.sec))
    res_a = getCategory()
    res_a.each{|a|
      #ジャンルごとのキーワードでスクレイピング開始（再生回数順）
      keyword =  a.text
      link =  a.attribute("href").value
      #@logfile.write("scraping: keyword=#{keyword}\n")
      @logger.info("scraping: keyword=#{keyword}\n")
      @url = "http://www.dmm.co.jp#{link}/sort=date/"
      scraping()
    }
    time = DateTime.now
    @logger.info(sprintf("[%d-%d-%d %d:%d:%d] end scraping(ByDate)",time.year,time.mon,time.mday,time.hour,time.min,time.sec))
  end
end
