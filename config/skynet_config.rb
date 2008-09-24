# Skynet Configuration File.  Should be in APP_ROOT/config/skynet_config.rb  
# Start skynet from within your app root with 
# > skynet start

require 'rubygems'
require 'skynet'         

# Load your rails app
if not defined?(RAILS_GEM_VERSION)
  require File.expand_path(File.dirname(__FILE__)) + '/../config/environment'
end

Skynet::CONFIG[:SKYNET_LOG_LEVEL] = Logger::ERROR
Skynet::CONFIG[:APP_ROOT]         = RAILS_ROOT
Skynet::CONFIG[:SKYNET_LOG_DIR]   = File.expand_path(Skynet::CONFIG[:APP_ROOT] + "/log")
Skynet::CONFIG[:SKYNET_PID_DIR]   = File.expand_path(Skynet::CONFIG[:APP_ROOT] + "/log")
Skynet::CONFIG[:SKYNET_LOG_FILE]  = "skynet_#{RAILS_ENV}.log"
Skynet::CONFIG[:SKYNET_PID_FILE]  = "skynet_#{RAILS_ENV}.pid"


Skynet::CONFIG[:MESSAGE_QUEUE_ADAPTER] = "Skynet::MessageQueueAdapter::TupleSpace"

# ==================================================================
# = Require any other libraries you want skynet to know about here =
# ==================================================================


# ===========================================
# = Set your own configuration options here =
# ===========================================
# You can also configure skynet with
# Skynet.configure(:SOME_CONFIG_OPTION => true, :SOME_OTHER_CONFIG => 3)

Skynet::CONFIG[:SKYNET_LOG_LEVEL]  = Logger::INFO
Skynet::CONFIG[:TS_USE_RINGSERVER] = false
Skynet::CONFIG[:NUMBER_OF_WORKERS] = 6
# Skynet::CONFIG[:MYSQL_NEXT_TASK_TIMEOUT]              = 30
# Skynet::CONFIG[:MYSQL_TEMPERATURE_CHANGE_SLEEP]       = 10
# Skynet::CONFIG[:MYSQL_MESSAGE_QUEUE_TEMP_CHECK_DELAY] = 10