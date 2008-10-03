class CreateFeedEntries < ActiveRecord::Migration
  def self.up
    create_table :feed_entries do |t|
      t.string  :title, :summary, :link
      t.text    :content
      t.integer :feed_id
      t.boolean :searched, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_entries
  end
end
