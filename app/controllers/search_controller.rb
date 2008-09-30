require 'net/http'
require 'query_generator'

class SearchController < ApplicationController
  
  def find 
    @search = Search.new(:url => params[:search])
    if @search.save
      job = DiscoverJob.new(:search_id => @search.id, :status => Job::STARTING)
      job.save
      session[:job_id] = job.id
      Workling::Remote.run(:discover_worker, :run, :job_id => job.id, :search_id => @search.id)
      render :template => '/shared/searching'
    end
  rescue Exception => e
    logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    redirect_to '/'
  end
  
  def update
    if request.xhr?
      dj = DiscoverJob.find_by_id(session[:job_id].to_i)
      if dj.status == Job::COMPLETE
        session[:job_id] = nil
        render :update do |page|
          page.redirect_to :action => 'show', :s => dj.search_id  
        end
      elsif dj.status == Job::ERROR
        session[:job_id] = nil
        render :update do |page|
          page.redirect_to :controller => 'search', :action => 'index'
        end
      else
        render :text => 'still working on highlighting copies of your content ...'
      end
    end
  rescue Exception => e
    logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    render :update do |page|
      session[:job_id] = nil
      page.redirect_to( '/')
    end
  end
  
  def show
    @search = Search.find_by_id params[:s]
    @results = @search.search_results.sort{|a,b| a.found_count<=>b.found_count}.reverse
  end

end
