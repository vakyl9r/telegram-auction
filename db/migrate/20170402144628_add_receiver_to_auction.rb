class AddReceiverToAuction < ActiveRecord::Migration[5.0]
  def change
    add_column :auctions, :receiver, :integer
  end
end
