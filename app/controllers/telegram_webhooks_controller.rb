class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include AbstractController::Rendering

  before_action :set_auction, except: [:auction, :sold, :rules, :declined, :start, :respond]
  before_action :participant_check, only: :callback_query
  #define_callbacks :auction, terminator: "result == false"
  before_action :verify_blacklist
  # after_action :end_price_check, only: [:raise_price, :bet]

  def start
    respond_with :message, text: "Здравствуйте, #{from['first_name']}! Вы были успешно " \
    "зарегистрированы!\n Добро пожаловать в комнату аукционов Skay BU."
  end

  def auction(auction_id)
    if start_auction(auction_id)
      if set_admin
        if @auction.receiver == from['id']
          send_lot_photos
          start_message
          bot.send_message(
            chat_id: @auction.receiver, text: "Аукцион по лоту #{@auction.name}",
            reply_markup: admin_keyboard
          )
        else
          not_authorized_message
        end
      end
    end
  end

  def rules
    respond_with :message, text: @@channel.rules, parse_mode: 'HTML'
  end

  def sold
    final_message('<b>Лот продан. Следите за анонсами новых торгов в канале.</b>')
  end

  def declined
    final_message('<b>Лот не продан. Будут новые торги по данному лоту, следите за анонсами в канале.</b>')
  end

  def callback_query(data)
    case data
    when 'participate'
      participate
    when 'bet'
      bet
    when 'set_own_price'
      set_own_price
    when 'end_auction'
      end_auction
    end
  end

  def message(message)
    can_raise?(message) ? raise_price(message) : decline_raise_price if message['reply_to_message']
  end

  def respond
    respond_to.json { status: :ok }
  end

  private

  def participate
    @auction.add_participant(
      { id: from['id'].to_s, first_name: from['first_name'], last_name: from['last_name'] }
    )
    bot.send_message chat_id: from['id'],
      text: "Вы принимаете участие в аукционе по лоту: '#{@auction.name}'\n" \
      "Текущая цена: #{@auction.current_price}$",
    reply_markup: keyboard
  end

  def bet
    @auction.bet
    @auction.save_in_history(
      {
        user_id: from['id'],
        full_name: "#{from['first_name']} #{from['last_name']}",
        username: from['username'],
        bet: @auction.current_price,
        time: Time.current.strftime('%F %H:%M')
      }
    )
    respond_with :message, text: "#{from['first_name']}, Вы подняли цену до #{@auction.current_price}$"
    remove_buttons
    auction_newsletter
    end_price_check
  end

  def set_own_price
    respond_with :message, text: 'Введите свою цену', reply_markup: {force_reply: true}
    remove_buttons
  end

  def send_lot_photos
    if @auction.image_1.present?
      bot.send_photo chat_id: @@channel.link, photo: File.open(@auction.image_1.path)
    end
    if @auction.image_2.present?
      bot.send_photo chat_id: @@channel.link, photo: File.open(@auction.image_2.path)
    end
  end

  def can_raise?(message)
    message['text'].to_f > @auction.current_price
  end

  def raise_price(message)
    @auction.set_price(message['text'].to_f)
    @auction.save_in_history({
      user_id: from['id'],
      full_name: "#{from['first_name']} #{from['last_name']}",
      username: from['username'],
      bet: @auction.current_price,
      time: Time.current.strftime('%F %H:%M')
    })
    respond_with :message, text: "#{from['first_name']}, Вы подняли цену до #{@auction.current_price}$"
    auction_newsletter
    end_price_check
  end

  def decline_raise_price
    respond_with :message,
      text: "Ваша ставка меньше текущей цены #{@auction.current_price}",
      reply_markup: keyboard
  end

  def remove_buttons
    bot.edit_message_reply_markup(chat_id: chat['id'],
      message_id: update['callback_query']['message']['message_id'])
  end

  def auction_newsletter
    last = @auction.history.last
    @auction.participants.map do |participant|
      if BannedUser.find_by(user_id: participant['id']).blank?
        if participant['id'] != last['user_id']
          bot.send_message chat_id: participant['id'],
          text: "#{participant['first_name']}, Вы принимаете участие в аукционе по лоту:" \
          "'#{@auction.name}'.\n#{last['full_name'].slice(0,3)}*** " \
          "поднял цену до #{@auction.current_price}$.", reply_markup: keyboard
        end
      end
    end
    if @auction.receiver
      bot.send_message(chat_id: @auction.receiver, text: "#{last['full_name']} поднял цену по лоту " \
      "#{@auction.name} до #{@auction.current_price}$.", reply_markup: admin_keyboard)
    end
    @@participants = @auction.participants
  end

  def end_auction
    if Sidekiq::ScheduledSet.new.size < 2
      if @auction.current_price >= @auction.end_price
        text = "Достигнут верхний предел цены по лоту '#{@auction.name}', до окончания аукциона осталось 5 минут."
      else
        text = "Аукцион по лоту: '#{@auction.name}' будет окончен через 5 минут."
      end
      @auction.participants.map do |participant|
        bot.send_message chat_id: participant['id'], text: text
      end
      bot.send_message chat_id: @auction.receiver, text: text
      StopAuctionJob.set(wait: 5.minutes).perform_later(@auction, chat['id'], update)
    end
  end

  def set_auction
    if from.present?
      @auction = Auction.find_by(active: true)
      if @auction.nil?
        bot.send_message chat_id: from['id'], text: 'Нет активных аукционов'
        throw :abort
      end
    else
      throw :abort
    end
  end

  def start_auction(id)
    @auction = Auction.find(id)
    if Auction.find_by(active: true).present?
      bot.send_message chat_id: from['id'], text: 'Уже есть активный аукцион!'
      return false
    else
      StopAuctionJob.set(wait: @auction.auction_time.minutes).perform_later(
        @auction, chat['id'], update
      )
      @auction.update!(active: true, current_price: @auction.start_price, history: [], participants: [])
      @@channel = Channel.find_by(link: @auction.channel)
    end
  end

  def verify_blacklist
    if from.present?
      if BannedUser.find_by(user_id: from['id']).present?
        bot.send_message chat_id: from['id'], text: 'Вы были забанены!'
        throw :abort
      end
    else
      throw :abort
    end
  end

  def keyboard
    kb = {
      inline_keyboard: [
        [{text: "Поднять ставку на #{@auction.bet_price}$", callback_data: 'bet'}],
        [{text: 'Указать свою цену', callback_data: 'set_own_price'}],
      ],
    }
  end

  def set_admin
    admins = bot.get_chat_administrators(chat_id: @@channel.link)['result']
    admins.any? do |admin|
      if admin['user']['id'] == from['id']
        @auction.update!(receiver: from['id'])
      end
    end
  end

  def admin_keyboard
    kb = {
      inline_keyboard: [
        [{text: "Закончить аукцион за #{@auction.current_price}$", callback_data: 'end_auction'}],
      ],
    }
  end

  def start_message
    bot.send_message chat_id: @@channel.link,
      text: "<b>#{@auction.name}</b>\n\n<b>Описание лота</b>: #{@auction.description}\n\n"\
      "<b>Стартовая цена</b>:#{@auction.start_price}$ \n\n"\
      "<b>!ВНИМАНИЕ!</b> Если Вы в первый раз участвуете в #аукционах в этом канале - "\
      "нажмите <b>'Зарегистрироваться'</b>.\nПосле этого, для участия "\
      "нажимайте: <b>'Участвовать в аукционе'</b>",
      parse_mode: 'HTML',
      reply_markup:{
        inline_keyboard: [
          [{text: 'Участвовать в аукционе', callback_data: 'participate'}],
          [{text: 'Зарегистрироваться', url: 'http://t.me/AuctionUA_bot'}],
        ],
      }
  end

  def send_history
    @auction.history.last(5).each do |winner|
      if winner['username']
        bot.send_message chat_id: @auction.receiver, text: "#{winner['full_name']}, "\
        "http://t.me/#{winner['username']} - ставка #{winner['bet']}\n"
      else
        bot.send_message chat_id: @auction.receiver, text: "#{winner['full_name']} - ставка #{winner['bet']}\n"
      end
    end
  end

  def not_authorized_message
    bot.send_message chat_id: from['id'], text: 'У вас нет прав для начала аукциона!'
  end

  def final_message(text)
    admins = bot.get_chat_administrators(chat_id: @@channel.link)['result']
    admins.any? do |admin|
      if admin['user']['id'] == from['id']
        bot.send_message chat_id: @@channel.link, text: text, parse_mode: 'HTML'
        @@participants.map do |participant|
          if BannedUser.find_by(user_id: participant['id']).blank?
            bot.send_message chat_id: participant['id'], text: text,
              parse_mode: 'HTML'
          end
        end
        bot.send_message chat_id: from['id'], text: 'Поздравляем! Вы решили судьбу лота!', reply_markup: {remove_keyboard: true}
      end
    end
  end

  def end_price_check
    if @auction.current_price >= @auction.end_price
      end_auction
    end
  end

  def participant_check
    if @auction.history.present?
      if @auction.history.last['user_id'].to_i == from['id']
        bot.send_message chat_id: from['id'], text: 'Ваша ставка последняя. Вы не можете повышать ставку.'
        throw :abort
      end
    end
  end
end
