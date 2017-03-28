class RemoveParticipantsFromAuction < ActiveRecord::Migration[5.0]
  def change
    remove_column :auctions, :participants, :string
  end
end
