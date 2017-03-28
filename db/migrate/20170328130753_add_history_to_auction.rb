class AddHistoryToAuction < ActiveRecord::Migration[5.0]
  def change
    add_column :auctions, :history, :hstore, default: {}, null: false
  end
end
