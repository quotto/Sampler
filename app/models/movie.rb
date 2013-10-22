class Movie < ActiveRecord::Base
  set_primary_key :dmm_id
  attr_accessible :dmm_id,:title,:thumbnail
end
