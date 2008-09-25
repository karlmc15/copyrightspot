#
# used to run the DiscoverManager asynchronously 

require 'discover_manager'

class DiscoverJob
  
  @@logger = Logger.new("#{RAILS_ROOT}/log/bj_discover_jobs.log")
  
  def self.do_work(search_id)
    begin
      @@logger.info("#{self} ** STARTED AT :: #{Time.now} :: WITH :: SEARCH :#{search_id}")
      
      DiscoverManager.run(search_id.to_i)
      
      @@logger.info("#{self} ** ENDED AT :: #{Time.now}")
    rescue Exception => e
      @@logger.error("#{self} **ERROR** ARGUMENTS SEARCH :#{search_id}")
      @@logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
      
      raise "ERROR IN #{self}"
    ensure
      @@logger.close
    end
  end
  
end

DiscoverJob.do_work(ARGV[0])