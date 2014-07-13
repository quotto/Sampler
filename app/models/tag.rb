class Tag < ActiveRecord::Base
  validates :dmm_id,:uniqueness=>{:scope=>:tag_name}
  # attr_accessible :dmm_id, :tag_name
end
