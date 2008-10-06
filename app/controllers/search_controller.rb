require 'net/http'
require 'query_generator'
require 'feed_tools'

class SearchController < ApplicationController
  
  protect_from_forgery :except => [:search_progress, :feed_progress]
  
  def find 
    #check if url is a blog and return a list of url that they can click
    url = params[:search]
    if url =~ /feed|rss|atom|rdf/
      feed = Feed.new(:url => params[:search])
      if feed.save
        session[:populate_feed] = feed.id
        @message = 'Give me a minute while I grab your blog feed'
        @update_url = url_for(:action => 'feed_progress')
        render :template => '/shared/searching'
      end
    else
      @search = WebPageSearch.new(:url => url)
      if @search.save
        session[:start_search] = @search.id
        @message = 'One minute while I Search the web'
        @update_url = url_for(:action => 'search_progress')
        render :template => '/shared/searching'
      end
    end
  rescue Exception => e
    logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    redirect_to '/'
  end
  
  def feed_progress
    if request.xhr?
      if session[:populate_feed]
        feed = Feed.find_by_id(session[:populate_feed].to_i)
        session[:populate_feed] = nil
        if feed.feed_entries.blank?
          entries = FeedTools::Feed.open(feed.url).entries
          entries.each do |entry|
            feed_entry = FeedEntry.new(:title => entry.title, :summary => entry.summary, :link => entry.link, :content => entry.content, :published => entry.published, :feed_id => feed.id)
            feed_entry.save
          end
        end
        render :update do |page|
          page.redirect_to :action => 'show_feed', :id => feed.id
        end
      end
    end
  rescue Exception => e
    logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    render :update do |page|
      session[:populate_feed] = nil
      page.redirect_to '/'
    end
  end
  
  def search_progress
    if request.xhr?
      # check first if any background process needs to be started    
      if session[:start_search]
        search_id = session[:start_search].to_i
        session[:start_search] = nil
        unless search_id.blank?
          job = DiscoverJob.new(:search_id => search_id, :status => Job::STARTING)
          job.save
          session[:job_id] = job.id
          # this is kind of expensive to create ... move to an ajax request
          Workling::Remote.run(:discover_worker, :run, :job_id => job.id, :search_id => search_id)
        end
        render :text => 'working on searching the web'
      else
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
          render :text => 'still working on searching the web'
        end
      end # end of start or check condition
    end
  rescue Exception => e
    logger.error "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    render :update do |page|
      session[:job_id] = nil
      session[:start_search] = nil
      page.redirect_to '/'
    end
  end
  
  def show_entry
    feed_entry = FeedEntry.find_by_id(params[:id])
    if feed_entry.searched
      redirect_to :action => 'show', :id => feed_entry.feed_entry_search
    else
      # create a search object 
      @search = FeedEntrySearch.new(:url => feed_entry.link, :feed_entry_id => feed_entry.id )
      if @search.save
        #update that this feed entry has been searched
        feed_entry.update_attribute(:searched, true)
        session[:start_search] = @search.id
        @message = 'One minute while I Search the web'
        @update_url = url_for(:action => 'search_progress')
        render :template => '/shared/searching'
      end
    end
  end
  
  def show_feed
    @feed = Feed.find_by_id params[:id].to_i
    @feed_entries = FeedEntry.paginate_by_feed_id(@feed.id, :page => params[:page], :per_page => 10, :order => 'created_at ASC')
  end
  
  def show
    @search = Search.find_by_id params[:id].to_i
    @results = SearchResult.paginate_by_search_id(@search.id, :page => params[:page], :per_page => 10, :order => 'found_count DESC')
  end

end
