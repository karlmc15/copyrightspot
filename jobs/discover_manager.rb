require 'rubygems'
require 'hpricot'

class DiscoverManager
  
  @@logger = Logger.new("#{RAILS_ROOT}/log/bj_discover_manager_jobs.log")
  
  def self.do_work(search_id)
    @@logger.info "#{self} - STARTED WORKER AT ********** #{Time.now} ****** THIS IS THE ID #{search_id}"
    @search = Search.find_by_id search_id
    doc = Hpricot(HtmlManager.get_html(@search.url) || '', :xhtml_strict => true)
    raise 'document is empty' if doc.nil?
    HtmlManager.strip_junk_tags(doc)
    # final collection of search strings with blanks removed
    word_array = HtmlManager.extract_text(doc)
    queries = QueryGenerator.search_terms(word_array)
    # hammer yahoo using distributed computing and collect sites who have copied content
    @@logger.info "ABOUT TO CALL SKYNET ************** #{Time.now}"
    sites = Discover.run(queries, @search.clean_url)
    sites = sites.flatten.uniq
    @@logger.info "DONE CALLING SKYNET ************** #{Time.now}"
    # update database with found words and sites
    @search.update_attributes(:search_text => encode(word_array), :found_urls => encode(sites))
    @@logger.info "#{self} - ENDED WORKER AT ********** #{Time.now}"
  end
  
  private
  
  def self.encode(array)
    Base64.encode64(array.join(','))
  end
  
  
end

DiscoverManager.do_work(ARGV)