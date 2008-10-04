# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081004230619) do

  create_table "copies", :force => true do |t|
    t.string   "url"
    t.string   "file_name"
    t.integer  "search_id"
    t.integer  "found_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feed_entries", :force => true do |t|
    t.string   "title"
    t.string   "summary"
    t.string   "link"
    t.text     "content"
    t.integer  "feed_id"
    t.boolean  "searched",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", :force => true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.string   "status"
    t.string   "type"
    t.text     "message"
    t.text     "error"
    t.integer  "search_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifies", :force => true do |t|
    t.string   "email"
    t.string   "page"
    t.boolean  "notified",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_results", :force => true do |t|
    t.string   "url"
    t.string   "dispurl"
    t.string   "title"
    t.text     "abstract"
    t.integer  "search_id"
    t.integer  "found_count", :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "searches", :force => true do |t|
    t.string   "url"
    t.string   "type"
    t.integer  "feed_entry_id"
    t.text     "search_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

end
