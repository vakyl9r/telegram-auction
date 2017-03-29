class AddAuctionTimeToAuction < ActiveRecord::Migration[5.0]
  def change
    add_column :auctions, :auction_time, :integer
  end
end
