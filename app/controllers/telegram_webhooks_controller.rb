class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  context_to_action!
  before_action :set_auction, :verify_blacklist

  def start
    respond_with :message, text: "Здравствуйте, #{from['first_name']}!. Вы были успешно " \
    "зарегистрированы!\n Добро пожаловать в комнату аукционов Skay BU."
  end

  def auction
    set_admin
    if $receiver == from['id']
      send_lot_photos
      start_message
    else
      not_authorized_message
    end
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
  end

  def set_own_price
    respond_with :message, text: 'Введите свою цену', reply_markup: {force_reply: true}
    remove_buttons
  end

  def send_lot_photos
    # also should be replaced with send_photo
    if @auction.image_1.present?
      bot.send_photo chat_id: '@autism_test', photo: File.open(@auction.image_1.path)
    end
    if @auction.image_2.present?
      bot.send_photo chat_id: '@autism_test', photo: File.open(@auction.image_2.path)
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
      unless BannedUser.find_by(user_id: participant['id']).present?
        if participant['id'] != last['user_id']
          bot.send_message chat_id: participant['id'],
          text: "#{participant['first_name']}, Вы принимаете участие в аукционе по лоту:" \
          "'#{@auction.name}'.\n#{last['full_name'].slice(0,3)}*** " \
          "поднял цену до #{@auction.current_price}$.", reply_markup: keyboard
        end
      end
    end
    if $receiver
      bot.send_message(chat_id: $receiver, text: "#{last['full_name']} поднял цену по лоту " \
      "#{@auction.name} до #{@auction.current_price}$.", reply_markup: admin_keyboard)
    end
  end

  def end_auction
    @auction.participants.map do |participant|
      bot.send_message chat_id: participant['id'],
      text: "#{participant['first_name']}, аукцион по лоту: '#{@auction.name}' окончен"
    end
    send_history
    @auction.update!(active: false)
    remove_buttons
    bot.send_message chat_id: $receiver, text: "Аукцион по лоту #{@auction.name} успешно закрыт"
  end

  def set_auction
    @auction = Auction.find_by(active: true)
    if @auction.nil?
      bot.send_message chat_id: from['id'], text: 'Нет активных аукционов'
      raise 'Auction Over'
    end
  end

  def verify_blacklist
    if BannedUser.find_by(user_id: from['id']).present?
      bot.send_message chat_id: from['id'], text: 'Вы были забанены!'
      raise 'In Blacklist'
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
    admins = bot.get_chat_administrators(chat_id: '@autism_test')['result']
    admins.each do |admin|
      if admin['user']['id'] == from['id']
        $receiver = from['id']
        return $receiver
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
    bot.send_message chat_id: '@autism_test',
      text: "Название: #{@auction.name}\nОписание: #{@auction.description}\nНачальная цена аукциона: "\
      "#{@auction.start_price}$\nВНИМАНИЕ! Если Вы в первый раз участвуете в аукционах от Skay BU - нажмите "\
      "'Зарегистрироваться'. ВНИМАНИЕ!\n"\
      "После этого, для участия в аукционе по данному лоту нажмите на соответствующую кнопку.",
      reply_markup:{
        inline_keyboard: [
          [{text: 'Участвовать в аукционе', callback_data: 'participate'}],
          [{text: 'Зарегистрироваться', url: 'http://t.me/SkayBU_bot'}],
        ],
      }
  end

  def send_history
    @auction.history.last(5).each do |winner|
      if winner['username']
        bot.send_message chat_id: $receiver, text: "#{winner['full_name']}, "\
        "http://t.me/#{winner['username']} - ставка #{winner['bet']}\n"
      else
        bot.send_message chat_id: $receiver, text: "#{winner['full_name']} - ставка #{winner['bet']}\n"
      end
    end
  end

  def not_authorized_message
    bot.send_message chat_id: from['id'], text: 'У вас нет прав для начала аукциона!'
  end
end
