class Feed < ActiveRecord::Base
  has_many :feed_entries, :dependent => :destroy
  
  validates_presence_of :url
  validates_format_of :url,
  :with => /(^(http|https|feed):\/\/[a-z0-9]+([-.]{1}[a-z0-9]*)+.[a-z]{1,5}(([0-9]{1,5})?\/.*)?$)/ix,
  :message => "is not valid"
  
  before_validation_on_create :clean_url
  
  private
  
  def clean_url
    u = self.url.downcase.gsub(' ', '')
    unless u =~ /(^(http|https|feed):\/\/)/
      u = 'http://' + u
    end
    self.url = u
  end
  
end
