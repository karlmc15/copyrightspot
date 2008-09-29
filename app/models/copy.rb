class Copy < ActiveRecord::Base
  has_one   :search
  has_many  :highlight_jobs, :dependent => :destroy
  
  def copy_doc
    @copy_doc ||= Hpricot(HtmlManager.get_html(self.url) || '', :xhtml_strict => true)
  end
  
  def get_html_with_nav(host)
    doc = Hpricot(self.html || '', :xhtml_strict => true)
    HtmlManager.set_html_base_url(doc, self.url)
    HtmlManager.set_head_navigation(doc, "/search/show?s=#{self.search_id}", self.found_count, host)
    doc.to_html
  end

  private 
  
  def encode_found_text(text_list)
    self.found_text = Base64.encode64(text_list.join(','))
  end
  
  def decode_found_text
    Base64.decode64(self.found_text).split(',')
  end

end
