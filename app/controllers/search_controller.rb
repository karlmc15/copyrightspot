require 'net/http'
require 'query_generator'

class SearchController < ApplicationController
  
  def results 
    @search = Search.new(:url => params[:search])
    if @search.save
      @entries = get_copy_sites 
      @search.set_found_urls @entries unless @entries.blank?
    end
  end
  
  def show
    @search = Search.find_by_id params[:s]
    @entries = @search.get_found_urls
  end
  
  private
  
  def get_copy_sites
    sites = []
    queries = @search.get_queries

    queries.each do |q|
      puts "THIS IS THE QUERY USED *****************************"
      pp q
      search = CGI.escape("#{q} -site:#{@search.clean_url}")
      req = "http://boss.yahooapis.com/ysearch/web/v1/#{search}?appid=R.3xNFTV34FQGQur.Ao9J17kyngB7458WBnwbpYK9BXQe4pqEGwSs.8F96tbPpkH&format=xml&count=10"
      resp = Net::HTTP.get_response(URI.parse(req))
      puts "HERE ARE THE RESPONSES *****************************"
      pp resp
      if resp.code.to_s == '403'
        puts "NOW BODY"
        pp resp.body
      end
      puts "------------------------"
      sites << parse_results(resp.body)
      puts "HERE ARE THE SITES FOUND **********************"
      pp parse_results(resp.body)
    end
    
    sites.flatten.uniq
  end
  
  def parse_results(xml)
    doc = Hpricot::XML xml
    entries = []
    (doc / '//result').each do |entry|
      entries << entry.at('/url').inner_text
    end
    entries
  end
  

  

end
