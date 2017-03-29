class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  context_to_action!
  before_action :set_auction

  def start
    response = from ? "Здравствуйте, #{from['first_name']}!" : 'Здравствуйте!'
    respond_with :message, text: response
    respond_with :message, text: 'Добро пожаловать в комнату аукционов Skay BU'
  end

  def auction
    send_lot_photos
    #should replace respond_with with send_message in order to interact with bot only through callback queries
    respond_with :message, text: "#{@auction.name}\nНачальная цена аукциона: #{@auction.start_price}$",
    reply_markup:{
      inline_keyboard: [
        [{text: 'Участвовать в аукционе!', callback_data: 'participate'}],
        [{text: 'Зарегистрироваться!', url: 'http://t.me/SkayBU_bot'}],
      ],
    }
  end

  def callback_query(data)
    case data
    when 'participate'
      participate
    when 'bet'
      bet
    when 'set_own_price'
      set_own_price
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
        bet: @auction.current_price
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
    respond_with :photo, photo: File.open(@auction.image_1.path)
    respond_with :photo, photo: File.open(@auction.image_2.path)
  end

  def can_raise?(message)
    message['text'].to_f > @auction.current_price
  end

  def raise_price(message)
    @auction.set_price(message['text'].to_f)
    @auction.save_in_history({
      user_id: from['id'],
      full_name: "#{from['first_name']} #{from['last_name']}",
      bet: @auction.current_price
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
      if participant['id'] != last['user_id']
        bot.send_message chat_id: participant['id'],
        text: "#{participant['first_name']}, Вы принимаете участие в аукционе по лоту:" \
        "'#{@auction.name}'.\n#{last['full_name'].slice(0,3)}*** " \
        "поднял цену до #{@auction.current_price}$.", reply_markup: keyboard
      end
    end
  end

  def set_auction
    @auction = Auction.find_by(active: true)
    # if false
    #   respond_with :message, text: 'Auction is over'
    #   raise 'Auction Over'
    # end
  end

  def keyboard
    kb = {
      inline_keyboard: [
        [{text: "Поднять ставку на #{@auction.bet_price}$", callback_data: 'bet'}],
        [{text: 'Указать свою цену', callback_data: 'set_own_price'}],
      ],
    }
  end
end
