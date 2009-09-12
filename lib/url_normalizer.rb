module UrlNormalizer
  class << self
    def normalize(uri)
      uri = uri.strip.sub(/^feed:\/\//, 'http://')
      /^http|https/.match(uri) ? uri : "http://#{uri}"
    end
  end
end