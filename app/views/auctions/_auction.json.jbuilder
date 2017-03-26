json.extract! auction, :id, :name, :image, :start_price, :bet, :current_price, :participants, :history, :created_at, :updated_at
json.url auction_url(auction, format: :json)
