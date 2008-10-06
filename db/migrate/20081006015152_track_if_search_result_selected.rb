class TrackIfSearchResultSelected < ActiveRecord::Migration
  def self.up
    add_column :copies, :search_result_id, :integer
    add_column :search_results, :searched, :boolean, :default => false
  end

  def self.down
    remove_column :copies, :column_name
    remove_column :search_results, :column_name
  end
end
