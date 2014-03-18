class AddDescColum < ActiveRecord::Migration
  def up
  	add_column :movies, :description, :string,:limit=>1000
  end

  def down
  	remove_column :movies, :description
  end
end
