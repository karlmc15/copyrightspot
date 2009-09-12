require 'curb'

module Http  
  class Gateway
    USER_AGENT = "CopyrightSpot: http://copyrightspot.com"
    # Pass in one or array of urls to take advantage of curl multi 
    # which will run http requests in parallel 
    def self.get(urls, options = {})
      url_queue = [*urls]
      multi = Curl::Multi.new
      responses = []
      url_queue.each do |url|
        url = UrlNormalizer.normalize url
        response  = Http::Response.new
        responses << response
        multi.add(setup_request(url, response, options))
      end
      multi.perform
      urls.is_a?(String) ? responses.first : responses
    end
    
    def self.get_head(url, options = {})
      url = UrlNormalizer.normalize url
      response  = Http::Response.new
      setup_request(url, response, options).http_head
      return response
    end
    
    private
    def self.setup_request(url, response, options)
      response.requested_url = url
      curl = Curl::Easy.new(url)
      curl.headers["User-Agent"]        = (options[:user_agent] || USER_AGENT)
      curl.headers["If-Modified-Since"] = options[:if_modified_since].httpdate if options.has_key?(:if_modified_since)
      curl.headers["If-None-Match"]     = options[:if_none_match] if options.has_key?(:if_none_match)
      curl.headers["Accept-Encoding"]   = 'gzip' if options.has_key?(:compress)
      curl.follow_location  = true
      curl.enable_cookies   = true
      curl.on_success { |c|
        response.last_effective_url = c.last_effective_url
        response.code     = c.response_code
        response.body     = c.body_str
        response.header   = c.header_str
        response.time     = c.download_speed
      }
      curl.on_failure { |c, e|
        response.code = c.response_code
      }
      return curl
    end
  end
end