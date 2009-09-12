require 'net/http'
require 'hpricot'

class Discover
    
  def self.run(queries, url, search_id)
    @sites = []
    responses = Boss::Gateway.web_search(queries, :site_url => url)
    @sites = responses.inject([]) do |col, resp|
      resp.result_set.each do |result|
        if result.url
          col << SearchResult.new(:url => scrub_result(result.url),
                                  :dispurl => scrub_result(result.dispurl),
                                  :title => scrub_result(result.title),
                                  :abstract => scrub_result(result.abstract))
        end
      end
      col.flatten
    end
    save_results(@sites, search_id)
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
  
  def self.scrub_result(str)
    doc = Hpricot(str)
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