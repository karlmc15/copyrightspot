class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string :status, :type
      t.text :message, :error
      t.integer :search_id
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
