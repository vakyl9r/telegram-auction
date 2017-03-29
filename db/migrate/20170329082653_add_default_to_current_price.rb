class AddDefaultToCurrentPrice < ActiveRecord::Migration[5.0]
  def change
    change_column :auctions, :current_price, :float, default: 0
  end
end
