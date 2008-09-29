class CreateSearchResults < ActiveRecord::Migration
  def self.up
    create_table :search_results do |t|
      t.string  :url, :dispurl, :title
      t.text    :abstract
      t.integer :search_id
      t.integer :found_count, :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :search_results
  end
end
