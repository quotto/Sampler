#coding utf-8
require 'nokogiri'
require 'net/http'

BITRATE_ID_300K = "sm_"
BITRATE_ID_1000K = "dm_"
BITRATE_ID_1500K = "dmb_"
ASPECT_SINGLE_MARK = "s"
ASPECT_WIDE_MARK = "w"
MP4_HOSTNAME = "cc3001.dmm.co.jp/litevideo/freepv/"
@logger = Logger.new("#{Rails.root}/log/update_movie_url.log",3,10 * 1024 * 1024)
time = DateTime.now
@logger.info(sprintf("[%d-%d-%d %d:%d:%d] start update movie_url",time.year,time.mon,time.mday,time.hour,time.min,time.sec))

Movie.transaction do
  movies = Movie.all
  movies.each {|movie|
    dmm_id = movie.dmm_id

    begin
      purl = URI.parse("http://www.dmm.co.jp/litevideo/-/detail/=/cid=#{dmm_id}/");	
      req = Net::HTTP::Get.new(purl.path)
      response = Net::HTTP.start(purl.host,purl.port) { |http|
        http.request(req);
      }
      if(response.code == '200')
        res_link = Nokogiri::HTML(response.body)
        
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
        movie.movie_url = mp4_url
        movie.save
        @logger.info("Update #{dmm_id},bip:#{bid} => #{mp4_url}")
      else
        @logger.warn("#{dmm_id} => not found page")
      end
    rescue => e
      @logger.error("Error #{dmm_id} => #{e.message}")
    end
    }
end

time = DateTime.now
@logger.info(sprintf("[%d-%d-%d %d:%d:%d] end update movie_url",time.year,time.mon,time.mday,time.hour,time.min,time.sec))