require 'net/http'
require 'query_generator'
require 'feed_tools'

class SearchController < ApplicationController
  
  def find 
    #check if url is a blog and return a list of url that they can click
    url = params[:search]
    if url =~ /feed|rss|atom|rdf/
      feed = Feed.new(:url => params[:search])
      if feed.save
        redirect_to :action => 'feed', :id => feed.id
      end
    else
      @search = WebPageSearch.new(:url => url)
      if @search.save
        job = DiscoverJob.new(:search_id => @search.id, :status => Job::STARTING)
        job.save
        session[:job_id] = job.id
        # this is kind of expensive to create ... move to an ajax request
        Workling::Remote.run(:discover_worker, :run, :job_id => job.id, :search_id => @search.id)
        render :template => '/shared/searching'
      end
    end
  rescue Exception => e
    logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    redirect_to '/'
  end
  
  def feed
    feed = Feed.find_by_id(params[:id])
    if feed.feed_entries.blank?
      entries = FeedTools::Feed.open(feed.url).entries
      @feed_entries = entries.inject([]) do |list, entry|
        feed_entry = FeedEntry.new(:title => entry.title, :summary => entry.summary, :link => entry.link, :content => entry.content, :feed_id => feed.id)
        if feed_entry.save
          list << feed_entry
        end
        list
      end
    else
      @feed_entries = feed.feed_entries
    end
  end
  
  def update
    if request.xhr?
      dj = DiscoverJob.find_by_id(session[:job_id].to_i)
      if dj.status == Job::COMPLETE
        session[:job_id] = nil
        render :update do |page|
          page.redirect_to :action => 'show', :id => dj.search_id  
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
  
  def show_entry
    feed_entry = FeedEntry.find_by_id(params[:id])
    unless feed_entry.searched
      # create a search object 
      @search = FeedEntrySearch.new(:url => feed_entry.link, :feed_entry_id => feed_entry.id )
      if @search.save
        #update that this feed entry has been searched
        feed_entry.update_attribute(:searched, true)
        job = DiscoverJob.new(:search_id => @search.id, :status => Job::STARTING)
        job.save
        session[:job_id] = job.id
        # this is kind of expensive to create ... move to an ajax request
        Workling::Remote.run(:discover_worker, :run, :job_id => job.id, :search_id => @search.id)
        render :template => '/shared/searching'
      end
    else
      redirect_to :action => 'show', :id => feed_entry.feed_entry_search.id
    end
  end
  
  def show
    @search = Search.find_by_id params[:id]
    @results = @search.search_results.sort{|a,b| a.found_count<=>b.found_count}.reverse
  end

end
