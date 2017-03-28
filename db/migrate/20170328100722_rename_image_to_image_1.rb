class RenameImageToImage1 < ActiveRecord::Migration[5.0]
  def change
    rename_column :auctions, :image, :image_1
  end
end
