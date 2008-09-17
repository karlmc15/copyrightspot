# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 2147483647) do

  create_table "bj_config", :primary_key => "bj_config_id", :force => true do |t|
    t.text "hostname"
    t.text "key"
    t.text "value"
    t.text "cast"
  end

  create_table "bj_job", :primary_key => "bj_job_id", :force => true do |t|
    t.text     "command"
    t.text     "state"
    t.integer  "priority"
    t.text     "tag"
    t.integer  "is_restartable"
    t.text     "submitter"
    t.text     "runner"
    t.integer  "pid"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.text     "env"
    t.text     "stdin"
    t.text     "stdout"
    t.text     "stderr"
    t.integer  "exit_status"
  end

  create_table "bj_job_archive", :primary_key => "bj_job_archive_id", :force => true do |t|
    t.text     "command"
    t.text     "state"
    t.integer  "priority"
    t.text     "tag"
    t.integer  "is_restartable"
    t.text     "submitter"
    t.text     "runner"
    t.integer  "pid"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.text     "env"
    t.text     "stdin"
    t.text     "stdout"
    t.text     "stderr"
    t.integer  "exit_status"
  end

  create_table "copies", :force => true do |t|
    t.string   "url"
    t.text     "found_text"
    t.text     "html"
    t.integer  "search_id"
    t.integer  "found_count"
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

  create_table "skynet_message_queues", :force => true do |t|
    t.integer  "queue_id",                                                  :default => 0
    t.integer  "tran_id",      :limit => 20
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "tasktype"
    t.integer  "task_id",      :limit => 20
    t.integer  "job_id",       :limit => 20
    t.text     "raw_payload"
    t.string   "payload_type"
    t.string   "name"
    t.integer  "expiry"
    t.decimal  "expire_time",                :precision => 16, :scale => 4
    t.integer  "iteration"
    t.integer  "version"
    t.decimal  "timeout",                    :precision => 16, :scale => 4
    t.integer  "retry",                                                     :default => 0
  end

  add_index "skynet_message_queues", ["tran_id"], :name => "index_skynet_message_queues_on_tran_id", :unique => true
  add_index "skynet_message_queues", ["job_id"], :name => "index_skynet_message_queues_on_job_id"
  add_index "skynet_message_queues", ["task_id"], :name => "index_skynet_message_queues_on_task_id"
  add_index "skynet_message_queues", ["queue_id", "tasktype", "payload_type", "expire_time"], :name => "index_skynet_mqueue_for_take"

  create_table "skynet_queue_temperature", :force => true do |t|
    t.integer  "queue_id",                                  :default => 0
    t.datetime "updated_on"
    t.integer  "count",                                     :default => 0
    t.decimal  "temperature", :precision => 6, :scale => 4
    t.string   "type"
  end

end
