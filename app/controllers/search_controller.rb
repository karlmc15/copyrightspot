require 'net/http'
require 'query_generator'

class SearchController < ApplicationController
  
  def find 
    @search = Search.new(:url => params[:search])
    if @search.save
       job = DiscoverJob.new(:search_id => @search.id, :status => Job::STARTING)
       job.save
      # session[:job_id] = job.id
      # Workling::Remote.run(:discover_worker, :run, :job_id => job.id, :search_id => @search.id)
      # render :template => '/shared/searching'
      DiscoverManager.run(@search.id, job.id)
      redirect_to :action => 'show', :s => @search.id 
    end
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
  rescue 
    logger.error("#{self} AJAX ADD PROGRESS ERRORS ** #{$!}")
    render :update do |page|
     session[:job_id] = nil
     page.redirect_to( '/')
    end
  end
  
  def show
    @search = Search.find_by_id params[:s]
    @results = @search.search_results.sort{|a,b| a.found_count<=>b.found_count}.reverse
  end
  
  private
  
  def get_copy_sites
    sites = []
    queries = @search.get_queries
    queries.each do |q|
      search = CGI.escape("#{q} -site:#{@search.clean_url}")
      req = "http://boss.yahooapis.com/ysearch/web/v1/#{search}?appid=R.3xNFTV34FQGQur.Ao9J17kyngB7458WBnwbpYK9BXQe4pqEGwSs.8F96tbPpkH&format=xml&count=10"
      resp = Net::HTTP.get_response(URI.parse(req))
      sites << parse_results(resp.body)
    end
    sites.flatten.uniq
  end
  
  def parse_results(xml)
    doc = Hpricot::XML xml
    entries = []
    (doc / '//result').each do |entry|
      entries << entry.at('/url').inner_text
    end
    entries
  end

end
