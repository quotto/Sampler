# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140224152245) do

  create_table "movies", :id => false, :force => true do |t|
    t.string   "dmm_id",     :null => false
    t.string   "title",      :null => false
    t.string   "thumbnail",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "movie_url"
  end

  add_index "movies", ["dmm_id"], :name => "index_movies_on_dmm_id", :unique => true

  create_table "query_counts", :force => true do |t|
    t.string   "query"
    t.integer  "count"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tags", :id => false, :force => true do |t|
    t.string   "dmm_id",     :null => false
    t.string   "tag_name",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "tags", ["dmm_id", "tag_name"], :name => "index_tags_on_dmm_id_and_tag_name", :unique => true

end
