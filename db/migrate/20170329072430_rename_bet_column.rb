class RenameBetColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :auctions, :bet, :bet_price
  end
end
