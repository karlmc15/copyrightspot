require 'hpricot'

class DiscoverManager
  
  def self.run(search_id)
    puts "#{self} - STARTED WORKER AT ********** #{Time.now} || #{search_id}"
    begin
      @search = Search.find_by_id search_id
	    doc = Hpricot(HtmlManager.get_html(@search.url) || '', :xhtml_strict => true)
	    raise 'document is empty' if doc.nil?
	    HtmlManager.strip_junk_tags(doc)
	    # final collection of search strings with blanks removed
	    word_array = HtmlManager.extract_text(doc)
	    queries = QueryGenerator.search_terms(word_array.flatten.uniq)
	    # hammer yahoo using distributed computing and collect sites who have copied content
	    sites = Discover.run(queries, @search.clean_url)
	    # update database with found words and sites
	    @search.update_attributes(:search_text => encode(word_array), :found_urls => encode(sites))
    rescue Exception => e
      puts "exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    end    
    puts "#{self} - ENDED WORKER AT ********** #{Time.now}"
  end
  
  private 
  
  def self.encode(array)
    Base64.encode64(array.join(','))
  end
  
end