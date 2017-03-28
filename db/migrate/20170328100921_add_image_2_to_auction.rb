class AddImage2ToAuction < ActiveRecord::Migration[5.0]
  def change
    add_column :auctions, :image_2, :string
  end
end
