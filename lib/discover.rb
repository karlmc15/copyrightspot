require 'net/http'
require 'hpricot'

class Discover
  
  YAHOO_APPID = "R.3xNFTV34FQGQur.Ao9J17kyngB7458WBnwbpYK9BXQe4pqEGwSs.8F96tbPpkH"
  
  def self.run(queries, url)
    pool = ThreadPool.new(20)
    @sites = []
    @url = url
    queries.each do |query|
      pool.dispatch(query) do |query|
        search = CGI.escape("#{query} -site:#{@url}")
        req = "http://boss.yahooapis.com/ysearch/web/v1/#{search}?appid=#{YAHOO_APPID}&format=xml&count=10"
        resp = Net::HTTP.get_response(URI.parse(req))
        @sites << parse_results(resp.body)
      end
    end
    pool.shutdown
    pool = nil
    @sites.flatten.uniq
  end
  
  private 
  
  def self.parse_results(xml)
    doc = Hpricot::XML xml
    (doc / '//result').inject([]) do |list, entry|
      list << entry.at('/url').inner_text
    end
  end
  
end