class Movie < ActiveRecord::Base
  self.primary_key = 'dmm_id'
  # attr_accessible :dmm_id,:title,:thumbnail,:movie_url,:description
end
