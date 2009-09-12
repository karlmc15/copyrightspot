require 'zlib'
require 'stringio'

module Http
  class Response 
    attr_accessor :code, :requested_url, :last_effective_url, :body, :header, :time

    def success?
      self.code == 200
    end
    
    # call this method if you passed in the :compress => true option to the gateway
    # cause the response could be gziped 
    def decompress_body
      if parsed_header['content-encoding'] == 'gzip'
        gzipped = StringIO.new(self.body)
        Zlib::GzipReader.new(gzipped).read
      else
        self.body
      end
    end
    
    def parsed_header
      self.header.split(/\n/).inject({}) do |col, val|
        h = val.strip.downcase.split(': ')
        if h.size >= 2
          if col.has_key?(key = h[0])
            unless col[key].to_s == h[1]
              if col[key].is_a?(Array)
                col[key] << h[1]
              else
                col[key] = [col[key], h[1]]
              end
            end
          else
            col[key] = h[1]
          end
        end
        col
      end
    end
    
  end
end