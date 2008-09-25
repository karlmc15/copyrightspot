#
# used to run the HighlightManager asynchronously 
class HighlightJob
  
  @@logger = Logger.new("#{RAILS_ROOT}/log/bj_highlight_jobs.log")
  
  def self.do_work(copy_id)
    begin
      @@logger.info("#{self} ** STARTED AT :: #{Time.now} :: WITH :: COPY :#{copy_id}")

      HighlightManager.run(copy_id.to_i)
      
      @@logger.info("#{self} ** ENDED AT :: #{Time.now}")
    rescue Exception => e
      @@logger.error("#{self} **ERROR** ARGUMENTS COPY :#{copy_id}")
      @@logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
      
      raise "ERROR IN #{self}"
    ensure
      @@logger.close
    end
  end
  
end

HighlightJob.do_work(ARGV[0])