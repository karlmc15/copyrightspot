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

ActiveRecord::Schema.define(:version => 20080921185700) do

  create_table "copies", :force => true do |t|
    t.string   "url"
    t.text     "found_text"
    t.text     "html"
    t.integer  "search_id"
    t.integer  "found_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discover_jobs", :force => true do |t|
    t.integer  "search_id"
    t.string   "status"
    t.text     "message"
    t.text     "error"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "highlight_jobs", :force => true do |t|
    t.integer  "copy_id"
    t.string   "status"
    t.text     "message"
    t.text     "error"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "searches", :force => true do |t|
    t.string   "url"
    t.text     "search_text"
    t.text     "found_urls"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
