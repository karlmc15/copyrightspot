require 'base64'
require 'uri'

class Search < ActiveRecord::Base
  has_many    :copies,          :dependent => :destroy
  has_many    :search_results,  :dependent => :destroy
  
  #before_create :set_search_text

  # this returns an array with all the search text
  # it checks if the object has it already created in base64 storage format in the sarch_text variable
  # if not it will create it and store it in base64 in search_text variable so it dosen't have to parse from html
  def get_search_text
    if self.search_text.nil?
      collect_search_text
    end
    decode_result_text(self.search_text)
  end
  
  def set_search_text(word_array)
    self.search_text = encode_result_text(word_array)
  end
  
  def get_queries
    QueryGenerator.search_terms(get_search_text)
  end
  
  def host
    host = URI.parse(self.url.gsub(/\s+/, '')).host
    if host.scan('.').size > 1
      host[host.index('.') + 1, host.size]
    end
    host
  end
  
  def print_search_text
    self.get_search_text.each do |text|
      puts "#{text}\n*********************\n***********************\n"
    end
  end
  
  private 
  
  def collect_search_text
    if self.search_text.nil?
      text_list = []
      text_list << HtmlManager.collect_search_text(self.url)
      self.search_text = encode_result_text(text_list)
    end
  end
  
  def encode_result_text(text_list)
    Base64.encode64(text_list.join(','))
  end
  
  def decode_result_text(glob)
    Base64.decode64(glob).split(',')
  end
  

end
