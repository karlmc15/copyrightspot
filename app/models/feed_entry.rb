class FeedEntry < ActiveRecord::Base
  belongs_to  :feed
  has_one    :feed_entry_search,  :dependent => :destroy
end
