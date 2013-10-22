class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies,:id=>false  do |t|
	  t.string :dmm_id,:null=>false
	  t.string :title,:null=>false
	  t.string :thumbnail, :null=>false
      t.timestamps
    end
	add_index :movies,:dmm_id,:unique=>true
  end
end
