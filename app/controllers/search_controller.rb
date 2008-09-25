require 'net/http'
require 'query_generator'

class SearchController < ApplicationController
  
  def find 
    @search = Search.new(:url => params[:search])
    if @search.save
      # discover manager returns job id
      jobs = Bj.submit "./script/runner ./jobs/discover_job.rb #{@search.id}", :tag => 'discover'     
      session[:job_id] = jobs.first.bj_job_id
      session[:job_search_id] = @search.id
      render :template => '/shared/searching'
    end
  end
  
  def update
    if request.xhr?
      bj = Bj.table.job.find(session[:job_id].to_i)
      if bj.finished?
        # completed without errors
        if bj.exit_status == 0
          render :update do |page| 
            session[:job_id] = nil
            search_id = session[:job_search_id].to_i
            session[:job_search_id] = nil
            page.redirect_to :action => 'show', :s => search_id        
          end    
        else         
          session[:job_id] = nil
          session[:job_search_id] = nil
          #handle errors
          render :update do |page|
            page.redirect_to :action => 'index'
          end
        end
      else
         render :text => 'still working on discovering your content ...'
      end
    else
       redirect_to '/'
    end
  rescue 
    logger.error("#{self} AJAX ADD PROGRESS ERRORS ** #{$!}")
    render :update do |page|
     session[:job_id] = nil
     session[:job_search_id] = nil
     page.redirect_to( '/')
    end
  end
  
  def show
    @search = Search.find_by_id params[:s]
    @entries = @search.get_found_urls
  end
  
  private
  
  def get_copy_sites
    sites = []
    queries = @search.get_queries
    puts "HERE ARE THE LIST OF QUERIES ****************"
    pp queries
puts "HERE IS THE START TIME OF YAHOO SEARCH ************************ #{Time.now}"
    queries.each do |q|
      # puts "THIS IS THE QUERY USED *****************************"
      # pp q
      search = CGI.escape("#{q} -site:#{@search.clean_url}")
      req = "http://boss.yahooapis.com/ysearch/web/v1/#{search}?appid=R.3xNFTV34FQGQur.Ao9J17kyngB7458WBnwbpYK9BXQe4pqEGwSs.8F96tbPpkH&format=xml&count=10"
      resp = Net::HTTP.get_response(URI.parse(req))
      # puts "HERE ARE THE RESPONSES *****************************"
      # pp resp
      # if resp.code.to_s == '403'
      #   puts "NOW BODY"
      #   pp resp.body
      # end
      # puts "------------------------"
      sites << parse_results(resp.body)
      # puts "HERE ARE THE SITES FOUND **********************"
      # pp parse_results(resp.body)
    end
puts "HERE IS THE END TIME OF YAHOO SEARCH ************************ #{Time.now}"    
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
