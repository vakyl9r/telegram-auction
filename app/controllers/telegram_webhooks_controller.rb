class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  context_to_action!
  before_action :set_auction

  def start
    response = from ? "Здравствуйте, #{from['first_name']}!" : 'Здравствуйте!'
    respond_with :message, text: response
    respond_with :message, text: "Добро пожаловать в комнату аукционов Skay BU"
  end

  def auction
    @auction.current_price = @auction.start_price if @auction.current_price.nil?
    #should replace respond_with with send_message in order to interact with bot only through callback queries
    respond_with :photo, photo: File.open(@auction.image_1.path)
    respond_with :photo, photo: File.open(@auction.image_2.path)
    respond_with :message, text: "#{@auction.name}\nНачальная цена аукциона: #{@auction.start_price}$",
    reply_markup:{
        inline_keyboard: [
          [{text: 'Участвовать в аукционе!', callback_data: 'participate'}],
          [{text: 'Зарегистрироваться!', url: 'http://t.me/SkayBU_bot'}],
        ],
      }
    # also should be replaced with send_photo
  end

  def callback_query(data)
    case data
    when 'participate'
      if @auction.participants.key?("#{from['id']}")
        bot.send_message chat_id: from['id'],
          text: "Вы уже являетесь участником аукциона по лоту \"#{@auction.name}\""
      else
        participants = @auction.participants
        participants["#{from['id']}"] = "#{from['first_name']} #{from['last_name']}"
        @auction.update(participants: participants)
        bot.send_message chat_id: from['id'],
          text: "Вы принимаете участие в аукционе по лоту: '#{@auction.name}'\n" \
          "Текущая цена: #{@auction.current_price}$",
        reply_markup: keyboard
      end
    when 'bet'
      bet = @auction.current_price + @auction.bet
      history = @auction.history
      history["#{bet}"] = "#{from['id']}"
      @auction.update(current_price: bet, history: history)
      respond_with :message, text: "#{from['first_name']}, Вы подняли цену до #{@auction.current_price}$"
      remove_buttons
      auction_newsletter
    when 'price'
      respond_with :message, text: 'Введите свою цену', reply_markup: {force_reply: true}
      remove_buttons
    end
  end

  def message(message)
    unless message['reply_to_message'].nil?
      price = message['text'].to_f
      if price > @auction.current_price
        history = @auction.history
        history["#{price}"] = "#{from['id']}"
        @auction.update(current_price: price, history: history)
        respond_with :message, text: "#{from['first_name']}, Вы подняли цену до #{@auction.current_price}$"
        auction_newsletter
      else
        respond_with :message, text: "Ваша ставка меньше текущей цены #{@auction.current_price}",
          reply_markup: keyboard
      end
    end
  end

  private

  def remove_buttons
    bot.edit_message_reply_markup(chat_id: chat['id'],
      message_id: update['callback_query']['message']['message_id'])
  end

  def auction_newsletter
    last = @auction.history.values.last.to_s
    @auction.participants.map do |participant_id, participant_name|
      if participant_id != last
        bot.send_message chat_id: participant_id,
        text: "#{participant_name}, Вы принимаете участие в аукционе по лоту:" \
        "'#{@auction.name}'.\n#{@auction.participants["#{last}"].slice(0,3)}*** " \
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
        [{text: "Поднять ставку на #{@auction.bet}$", callback_data: 'bet'}],
        [{text: 'Указать свою цену', callback_data: 'price'}],
      ],
    }
  end
end
