class SearchResult < ActiveRecord::Base
  belongs_to :search
  has_one :copy
end
