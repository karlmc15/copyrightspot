MONITOR_LOGGER = Logger.new("#{RAILS_ROOT}/log/monitor.log")

class MonitorLogger
  
  def self.monitor(text)
    MONITOR_LOGGER.info("**********")
    MONITOR_LOGGER.info(text)
    MONITOR_LOGGER.info("**********")
  end
  
  def self.info(text)
    MONITOR_LOGGER.info(text)
  end
  
end