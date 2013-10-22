class SamplerController < ApplicationController
  def index
    #ランダムに30件取得する
    @movies = Movie.find(:all,:select=>"dmm_id,title,thumbnail",:limit=>30,:order=>"RAND()")
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def search
    keyword = params[:keyword]
    @query = keyword    
    keyword_arr = keyword.split();
    if(keyword_arr.length == 0)
      #検索ワードが検出できない場合は全検索処理を行う
      index
    else
      @movies = searchByKeyword(keyword_arr)
      keyword_arr.each {|query|
        queryCount = QueryCount.arel_table
        if QueryCount.exists?(:query=>query)
          queryResult = QueryCount.where(queryCount[:query].eq(query)).first
          count = queryResult.count + 1
          queryResult.update_attributes(:count=>count);
        else
          newQuery = QueryCount.new(:query=>query,:count=>1)
          newQuery.save
        end
      }

      if @movies.length > 0  
        render 'index'
      else
        render 'notfound'
      end
    end
  end
  
  def refresh
    keyword = params[:keyword]
    keyword_arr = keyword.split();
    if keyword_arr ==nil || keyword_arr.length == 0
      #ランダムに30件取得する
      @movies = Movie.find(:all,:select=>"dmm_id,title,thumbnail",:limit=>30,:order=>"RAND()")
    else
      @movies =  searchByKeyword(keyword_arr)
    end
    render :xml => @movies, :status=>'200'
    
  end
  
  def searchByKeyword(keyword_arr)
    movies = Movie.arel_table
    tags = Tag.arel_table

    movie_cond = movies[:title].matches("%#{keyword_arr[0]}%")
    for i in 1..keyword_arr.length-1 do
      movie_cond = movie_cond.and(movies[:title].matches("%#{keyword_arr[i]}%"))
    end
      
    tag_cond = tags.project(Arel.sql('dmm_id')).where(tags[:dmm_id].eq(movies[:dmm_id]).and(tags[:tag_name].matches("%#{keyword_arr[0]}%"))).exists
    for i in 1..keyword_arr.length-1 do
      tag_cond = tag_cond.and(tags.project(Arel.sql('dmm_id')).where(tags[:dmm_id].eq(movies[:dmm_id]).and(tags[:tag_name].matches("%#{keyword_arr[i]}%"))).exists)
    end
    return Movie.where(movie_cond.or(tag_cond)).limit(30).order("RAND()")
  end
end
