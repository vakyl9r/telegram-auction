class AddParticipantsToAuction < ActiveRecord::Migration[5.0]
  def change
    add_column :auctions, :participants, :hstore, default: {}, null: false
  end
end
