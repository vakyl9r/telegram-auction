class AddDescriptionToAuction < ActiveRecord::Migration[5.0]
  def change
    add_column :auctions, :description, :text
  end
end
