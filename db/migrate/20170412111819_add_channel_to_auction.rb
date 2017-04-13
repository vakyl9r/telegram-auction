class AddChannelToAuction < ActiveRecord::Migration[5.0]
  def change
    add_column :auctions, :channel, :string
  end
end
