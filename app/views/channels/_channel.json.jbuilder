json.extract! channel, :id, :name, :link, :created_at, :updated_at
json.url channel_url(channel, format: :json)
