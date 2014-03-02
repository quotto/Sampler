#coding utf-8
require 'nokogiri'
require 'net/http'
require 'logutil.rb'

BITRATE_ID_300K = "sm_"
BITRATE_ID_1000K = "dm_"
BITRATE_ID_1500K = "dmb_"
ASPECT_SINGLE_MARK = "s"
ASPECT_WIDE_MARK = "w"
MP4_HOSTNAME = "cc3001.dmm.co.jp/litevideo/freepv/"
@logfile = LogUtil.new("#{Rails.root}/log/update_movie_url.log","#{Rails.root}/log/update_movie_url.log")

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
        puts "bid:#{bid},bitRate:#{bitRate}"
        mp4_url = MP4_HOSTNAME + dmm_id[0,1] + "/" + dmm_id[0,3] + "/" + dmm_id + "/" + dmm_id + "_" + bitRate + aspectMark + ".mp4"
        movie.movie_url = mp4_url
        movie.save
        @logfile.write("[update]#{dmm_id},bip:#{bid} => #{mp4_url}")
      else
        puts "not found page at #{dmm_id}"
      end
    rescue => e
      @logfile.write("[error]#{dmm_id} => #{e.message}")
    end
    }
end
