class AddPublishedToFeedResult < ActiveRecord::Migration
  def self.up
    add_column :feed_entries, :published, :string
  end

  def self.down
    remove_column :feed_entries, :published
  end
end
