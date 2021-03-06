require 'fileutils'

class Copy < ActiveRecord::Base

  belongs_to :search_result
  belongs_to   :search

  before_create :create_file_name
  
  BASE_DIR = File.join(RAILS_ROOT, 'public', 'copy_html')
  
  def copy_doc
    @copy_doc ||= Hpricot(HtmlManager.get_html(self.url) || '', :xhtml_strict => true)
  end
  
  def save_html(html)
    path = File.join(BASE_DIR, self.search_id.to_s, self.id.to_s)
    FileUtils.mkdir_p(path)    
    File.open("#{path}/#{self.file_name}.html", 'w') { |f| f.write(html) }
  end
  
  def get_html_path
    path = File.join(BASE_DIR, self.search_id.to_s, self.id.to_s)
    "#{path}/#{self.file_name}.html"
  end
  
  def set_nav_in_html(html)
    doc = Hpricot(html)
    HtmlManager.set_html_base_url(doc, self.url)
    HtmlManager.set_head_navigation(doc, self.id)
    doc.to_html
  end

  private 

  def create_file_name
    self.file_name = Digest::SHA1.hexdigest((Time.now.to_i - rand(1000000)).to_s).slice(0,25)
  end
  
  def encode_found_text(text_list)
    self.found_text = Base64.encode64(text_list.join(','))
  end
  
  def decode_found_text
    Base64.decode64(self.found_text).split(',')
  end

end
