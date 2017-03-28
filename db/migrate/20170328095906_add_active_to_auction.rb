class AddActiveToAuction < ActiveRecord::Migration[5.0]
  def change
    add_column :auctions, :active, :boolean, default: false
  end
end
