class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags,:id=>false do |t|
	  t.string :dmm_id,:null=>false
	  t.string :tag_name,:null=>false
      t.timestamps
    end
	add_index :tags,[:dmm_id,:tag_name],:unique=>true
  end
end
