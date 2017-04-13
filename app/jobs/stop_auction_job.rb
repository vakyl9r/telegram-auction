class StopAuctionJob < ApplicationJob
  queue_as :default

  def perform(auction, chat_id, update)
    if auction.active
      auction.update!(active: false)
      auction.participants.map do |participant|
        Telegram.bot.send_message chat_id: participant['id'],
        text: "#{participant['first_name']}, аукцион по лоту: '#{auction.name}' окончен. "\
        "Мы связываемся с последним претендентом на лот для подтверждения покупки."
      end
      send_history(auction)
      remove_buttons(chat_id, update)
      Telegram.bot.send_message chat_id: auction.receiver, text: "Аукцион по лоту #{auction.name} успешно закрыт"
      destroy_sidekiq_jobs
    end
  end

  private

  def send_history(auction)
    auction.history.last(5).each do |winner|
      if winner['username']
        Telegram.bot.send_message chat_id: auction.receiver, text: "#{winner['full_name']}, "\
        "http://t.me/#{winner['username']} - ставка #{winner['bet']}\n"
      else
        Telegram.bot.send_message chat_id: auction.receiver, text: "#{winner['full_name']} - ставка #{winner['bet']}\n"
      end
    end
    Telegram.bot.send_message chat_id: auction.receiver, text: "<b>Решите судьбу лота!</b> \n" \
      "/sold - лот продан, /declined - отказ от продажи.", parse_mode: 'HTML',
      reply_markup: {
        keyboard: [
          [{text: '/sold'}],
          [{text: '/declined'}],
        ], one_time_keyboard: true
      }
  end

  def remove_buttons(chat_id, update)
    if update['callback_query'].present?
      Telegram.bot.edit_message_reply_markup(chat_id: chat_id,
        message_id: update['callback_query']['message']['message_id'])
    end
  end

  def destroy_sidekiq_jobs
    scheduled = Sidekiq::ScheduledSet.new
    scheduled.each do |job|
      job.delete
    end
  end
end
