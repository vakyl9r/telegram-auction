class RemoveHistoryFromAuction < ActiveRecord::Migration[5.0]
  def change
    remove_column :auctions, :history, :string
  end
end
