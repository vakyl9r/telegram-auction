class ChangeHstoreToArray < ActiveRecord::Migration[5.0]
  def change
    remove_column :auctions, :participants, :hstore
    remove_column :auctions, :history, :hstore
    add_column :auctions, :participants, :hstore, array: true, default: [], null: false
    add_column :auctions, :history, :hstore, array: true, default: [], null: false
  end
end
