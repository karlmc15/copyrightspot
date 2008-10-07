require 'log4r'

class DiscoverLogger
  include Log4r
  
  def self.method_missing(*args)
    logger.send(args.shift, args.to_s)
  end
  
  def self.logger
    @@logger ||= get_logger 
  end
  
  private 
  
  def self.get_logger
    Logger.new("discover")
    FileOutputter.new('discover', :filename=>"#{RAILS_ROOT}/log/discover.log", :trunc=>false)
    Logger['discover'].add 'discover'
    Logger['discover']
  end
  
end