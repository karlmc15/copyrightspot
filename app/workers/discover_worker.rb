class DiscoverWorker < Workling::Base
  
  def run(options)
    DiscoverManager.run(options[:search_id], options[:job_id])
  end
  
end