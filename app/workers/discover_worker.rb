require 'html_manager'
require 'query_generator'
require 'discover'
require 'discover_job'
require 'job'
require 'search'

class DiscoverWorker < Workling::Base
  
  def run(options)
    logger.info "** #{self} STARTING TO MANAGE SEARCH ********** #{Time.now} SEARCH ID -- #{options[:search_id]}"
    begin
      @search = Search.find_by_id(options[:search_id].to_i)
      @job = DiscoverJob.find_by_id(options[:job_id].to_i)
      @job.update_attribute(:status, Job::WORKING)
      # check if we have a blog and set html accordingly
      html = (@search.class == FeedEntrySearch ? form_feed_html(@search) : HtmlManager.get_html(@search.url))
	    doc = Hpricot( html || '', :xhtml_strict => true)
	    raise 'document is empty' if doc.nil?
	    HtmlManager.strip_junk_tags(doc)
	    HtmlManager.remove_junk_content(doc)
	    # final collection of search strings with blanks removed
	    search_hash = HtmlManager.extract_text(doc)
	    queries = QueryGenerator.search_terms(search_hash)
	    # hammer yahoo using distributed computing and collect sites who have copied content
	    sites = Discover.run(queries, @search.host, options[:search_id])
	    # update database with found words and sites
	    @search.update_attributes(:search_text => encode(search_hash.values.flatten.uniq))
	    @job.update_attribute(:status, Job::COMPLETE)
	    logger.info "** #{self} ENDING SEARCH MANAGEMENT ********** #{Time.now} -- NUMBER OF FOUND SITES = #{sites.size unless sites.nil?}"
    rescue Exception => e
      @job.update_attribute(:status, Job::ERROR)
      logger.error "#{self} -- exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    end    
  end
  
  private 
  
  def encode(array)
    Base64.encode64(array.join(','))
  end
  
  def form_feed_html(search)
    html = ''
    html << "<h1>#{search.feed_entry.title}</h1>"
    html << search.feed_entry.content
    # make sure the html is tidy
    HtmlManager.tidy_html(html)
  end
  
end