class CreateAuctions < ActiveRecord::Migration[5.0]
  def change
    create_table :auctions do |t|
      t.string :name
      t.string :image
      t.float :start_price
      t.float :bet
      t.float :current_price
      t.string :participants
      t.string :history

      t.timestamps
    end
  end
end
