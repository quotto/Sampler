#coding:utf-8

require 'nokogiri'
require 'net/http'

@logger = Logger.new("#{Rails.root}/log/update_movie_desc.log",3,10 * 1024 * 1024)
time = DateTime.now
@logger.info(sprintf("[%d-%d-%d %d:%d:%d] start update movie_description",time.year,time.mon,time.mday,time.hour,time.min,time.sec))

Movie.transaction do 
	movies = Movie.where(:description=>nil)
	movies.each{|movie|
		dmm_id = movie.dmm_id
		begin
			purl = URI.parse("http://www.dmm.co.jp/litevideo/-/detail/=/cid=#{dmm_id}/")
			req = Net::HTTP::Get.new(purl.path)
			response = Net::HTTP.start(purl.host,purl.port) {|http|
				http.request(req)
			}
			if(response.code == '200')
				res_link = Nokogiri::HTML(response.body)

				#詳細を取得
				description = res_link.css("#tx-description").text
				movie.description = description
				movie.save!
				@logger.info("Update description:id=>#{dmm_id},#{description}")
			end
		rescue => e
			@logger.info("Failed Update description:id=>#{dmm_id},#{e.message}")
		end
	}
end

time = DateTime.now
@logger.info(sprintf("[%d-%d-%d %d:%d:%d] end update movie_description",time.year,time.mon,time.mday,time.hour,time.min,time.sec))
