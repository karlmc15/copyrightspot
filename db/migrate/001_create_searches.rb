class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.string  :url, :type
      t.integer :feed_entry_id
      t.text    :search_text
      t.timestamps
    end
  end

  def self.down
    drop_table :searches
  end
end
