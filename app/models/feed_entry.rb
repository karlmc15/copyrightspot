require 'hpricot'

class FeedEntry < ActiveRecord::Base
  belongs_to  :feed
  has_one     :feed_entry_search,  :dependent => :destroy
  
  def clean_abstract
    doc = Hpricot(self.summary, :xhtml_strict => true)
    return '' if doc.nil?
    doc.to_plain_text
    abs = doc.inner_text
    (abs.length > 100 ? "#{abs[0..100]}..." : abs)
  end
  
end
