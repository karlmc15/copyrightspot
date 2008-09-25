class CreateCopies < ActiveRecord::Migration
  def self.up
    create_table :copies do |t|
      t.string :url
      t.text  :found_text, :html
      t.integer :search_id, :found_count
      t.timestamps
    end
  end

  def self.down
    drop_table :copies
  end
end
