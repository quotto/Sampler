class CreateQueryCounts < ActiveRecord::Migration
  def change
    create_table :query_counts do |t|
      t.string :query
	  t.integer :count
      t.timestamps
    end
  end
end
