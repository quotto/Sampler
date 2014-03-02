class AddColumnUrl < ActiveRecord::Migration
  def up
  	add_column :movies, :movie_url, :string
  end

  def down
  	remove_column :movies, :movie_url
  end
end
