##
# Use SkyNet MapReduce to search through Yahoo BOSS to find sites with potential reuse of original sites content
require 'net/http'
require 'hpricot'

class Discover
  include SkynetDebugger

  def self.run(queries, url)
    # we need to pass in the url in map_data to form search query for yahoo 
    # so we create a two dimesional array with query and url
    query_map_data = queries.inject([]){|map_data,query| map_data << [query, url]}
    job = Skynet::Job.new(
      :mappers          => 6,
      :reducers         => 1,
      :map_reduce_class => self,
      :map_data         => query_map_data
    )    
    results = job.run
  end
  
  def self.map(query_map_data)
    query_map_data.inject([]) do |sites, map_data|
      info "THIS IS THE QUERY USED ***************************** #{map_data[0]}"
      search = CGI.escape("#{map_data[0]} -site:#{map_data[1]}")
      req = "http://boss.yahooapis.com/ysearch/web/v1/#{search}?appid=R.3xNFTV34FQGQur.Ao9J17kyngB7458WBnwbpYK9BXQe4pqEGwSs.8F96tbPpkH&format=xml&count=10"
      resp = Net::HTTP.get_response(URI.parse(req))
      info "HERE IS THE RESPONSE CODE ***************************** #{resp.code}"
      sites << parse_results(resp.body)
    end
  end
  
  # def self.reduce(urls)
  #   urls.flatten.uniq
  # end
  
  private 
  
  def self.parse_results(xml)
    doc = Hpricot::XML xml
    entries = []
    (doc / '//result').each do |entry|
      entries << entry.at('/url').inner_text
    end
    entries
  end
  
end