require 'net/http'
require 'hpricot'

class Discover
  
  YAHOO_APPID = "y_UjZJ7V34HtVixluMcJ_JsCZkdJ_8dTPskUVD0hSzW6TO3p21j7GEjc.CLE8Ko3"
  
  @@logger = DiscoverLogger.logger
  
  def self.run(queries, url, search_id)
    pool = ThreadPool.new(20)
    @sites = []
    @url = url
    queries.each do |query|
      pool.dispatch(query) do |query|
        search = CGI.escape("#{query} -site:#{@url}")
        @@logger.info "** HERE IS THE QUERY ABOUT TO BE RUN ** #{query}"
        req = "http://boss.yahooapis.com/ysearch/web/v1/#{search}?appid=#{YAHOO_APPID}&format=xml&count=10"
        resp = Net::HTTP.get_response(URI.parse(req))
        if resp.code.to_s == '404'
          @@logger.info "** 404 RESPONSE FROM YAHOO FOR THIS URL: #{url} AND QUERY -- #{search}"
        end
        @sites << parse_results(resp.body)
      end
    end
    pool.shutdown
    pool = nil
    save_results(@sites.flatten!, search_id)
  rescue Exception => e
    @@logger.error "#{self} -- exception caught: " + e.class.to_s + " inspection: " + e.inspect + "\n" + e.backtrace.join("\n")
    # return an empty array so the functionality still appears to work
    return Array.new
  end
  
  private 
  
  def self.save_results(results, search_id)
    unless results.blank?
      ensure_results_unique(results).each do |result|
        result.search_id = search_id
        result.save
      end  
    end
  end
  
  def self.parse_results(xml)
    doc = Hpricot::XML xml
    (doc / '//result').inject([]) do |list, entry|
      results = {
        :url => scrub_result(entry.at('/url')),
        :dispurl => scrub_result(entry.at('/dispurl')),
        :title => scrub_result(entry.at('/title')),
        :abstract => scrub_result(entry.at('/abstract'))
        }
      list << SearchResult.new(results)
    end
  end
  
  def self.scrub_result(elem)
    doc = Hpricot(elem.inner_text)
    doc.to_plain_text
    doc.inner_text
  end
  
  def self.ensure_results_unique(results)
    results.inject([]) do |list, result|
      if list.collect(&:url).include?(result.url)
        #find which result and update it's count
        list.each do |sr|
          if sr.url == result.url
            sr.found_count += 1
            break
          end
        end
      else
        # add to list
        list << result
      end
      list
    end
  end
  
end