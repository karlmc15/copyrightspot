require 'log4r'

class MonitorLogger
  include Log4r
  
  def self.method_missing(*args)
    logger.send(args.shift, args.to_s)
  end
  
  def self.logger
    @@logger ||= get_logger 
  end
  
  private 
  
  def self.get_logger
    Logger.new("monitor")
    FileOutputter.new('monitor', :filename=>"#{RAILS_ROOT}/log/monitor.log", :trunc=>false)
    Logger['monitor'].add 'monitor'
    Logger['monitor']
  end
  
end