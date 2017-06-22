class ClosureWarningJob < ApplicationJob
  queue_as :default

  def perform(auction)
    if auction.active
      text = "Аукцион по лоту: '#{auction.name}' будет окончен через 5 минут."
      auction.participants.map do |participant|
        Telegram.bot.send_message chat_id: participant['id'], text: text
      end
      Telegram.bot.send_message chat_id: auction.receiver, text: text
    end
  end
end
