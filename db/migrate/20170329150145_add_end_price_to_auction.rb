class AddEndPriceToAuction < ActiveRecord::Migration[5.0]
  def change
    add_column :auctions, :end_price, :float
  end
end
