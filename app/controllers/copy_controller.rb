class CopyController < ApplicationController
  
  def show
    search = Search.find_by_id params[:s]
    @copy = Copy.new(:url => params[:url])
    @copy.locate_copied_text(search.get_search_text, url_for(:controller => 'search', :action => 'show', :s => search.id))
  end
  
end
