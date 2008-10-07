require 'log4r'

class HighlightLogger
  include Log4r
  
  def self.method_missing(*args)
    logger.send(args.shift, args.to_s)
  end
  
  def self.logger
    @@logger ||= get_logger 
  end
  
  private 
  
  def self.get_logger
    Logger.new("highlight")
    FileOutputter.new('highlight', :filename=>"#{RAILS_ROOT}/log/highlight.log", :trunc=>false)
    Logger['highlight'].add 'highlight'
    Logger['highlight']
  end
  
end