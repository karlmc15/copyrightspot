class CreateNotifies < ActiveRecord::Migration
  def self.up
    create_table :notifies do |t|
      t.string  'email', 'page'
      t.boolean :notified, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :notifies
  end
end
