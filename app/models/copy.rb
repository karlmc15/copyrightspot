class Copy < ActiveRecord::Base
  has_one :search
  
  def locate_copied_text(original_url, return_url)
    setup_search_docs
    html, count = HtmlManager.highlight_copied_text(original_url, @original_doc)
    doc = Hpricot(html || '', :xhtml_strict => true)
    self.found_count = count
    #encode_found_text(found_text_list)
    HtmlManager.set_html_base_url(doc, self.url)
    HtmlManager.set_head_navigation(doc, return_url, count)
    self.html = doc.to_html
  end


  private 
  
  def encode_found_text(text_list)
    self.found_text = Base64.encode64(text_list.join(','))
  end
  
  def decode_found_text
    Base64.decode64(self.found_text).split(',')
  end
  
  def setup_search_docs
    original_html   = HtmlManager.get_html(self.url) 
    @original_doc   = Hpricot(original_html || '', :xhtml_strict => true)
  end

end
