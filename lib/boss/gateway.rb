module Boss
  class Gateway
    YAHOO_API_KEY = 'y_UjZJ7V34HtVixluMcJ_JsCZkdJ_8dTPskUVD0hSzW6TO3p21j7GEjc.CLE8Ko3'
    
    # call with a single string query or an array of queries
    # this will use curl multi to process the requests in parallel
    # pass in :site_url => 'site url' in the options if you want to omit it from the search results
    def self.web_search(queries, options = {})
      query_queue = [*queries]
      requests = query_queue.inject([]) do |col, query|
        search = CGI.escape(options.has_key?(:site_url) ? "#{query} -site:#{options[:site_url].gsub(/https?:\/\/(www.)?/, '')}" : "#{query}")
        col << endpoint_url('web') + "#{search}?appid=#{YAHOO_API_KEY}&format=json&count=50"
      end
      requests = requests.first if queries.is_a?(String)
      resp = Http::Gateway.get(requests, :compress => true)
      if queries.is_a?(String)
        Boss::Response.new(parse_response(resp.decompress_body), 'web')
      else
        resp.collect{|r| Boss::Response.new(parse_response(r.decompress_body), 'web')}
      end
    end
    
    def self.pagedata_search(domain, options = {})
      search = CGI.escape("#{domain}")
      req = endpoint_url('se_pagedata') + "#{search}?appid=#{YAHOO_API_KEY}&format=json&count=50"
      resp = Http::Gateway.get(req, :compress => true)
      Boss::Response.new(parse_response(resp.decompress_body), 'se_pagedata')
    end
    
    private 
    
    def self.parse_response(json)
      results = if defined? ActiveSupport::JSON
        ActiveSupport::JSON.decode(json)
      else
        JSON.parse(json)
      end
    end
    
    def self.endpoint_url(method)
      "http://boss.yahooapis.com/ysearch/#{method}/v1/"
    end
    
  end
end