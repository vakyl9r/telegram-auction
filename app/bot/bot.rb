# # require 'telegram/bot'
# # require 'pry'
# token = '287792996:AAEkvHSISrFSPXe_ZBEY4b0aPqB_3VKhh5o'

# auction = {
#   id: 1,
#   name: 'Alex',
#   image: '../assets/images/tratata.jpg',
#   start_price: 10.0,
#   bet: 5.0,
#   current_price: 10.0,
#   participants: {},
#   history: {}
# }

# def keyboard(auction)
#   kb = [
#     Telegram::Bot::Types::InlineKeyboardButton.new(text: "Поднять ставку на #{auction[:bet]}$", callback_data: 'bet'),
#     Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Указать свою цену', callback_data: 'price')
#   ]
#   markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
# end

# def auction_message(bot, message, auction)
#   current_price = auction[:current_price]
#   bot.api.send_message(chat_id: message.from.id, text: "Вы принимаете участие в аукционе по лоту: \"#{auction[:name]}\"\nТекущая цена: #{current_price}$", reply_markup: keyboard(auction))
# end

# def auction_update(bot, message, auction)
#   current_price = auction[:current_price]
#   auction[:history]["#{current_price}"] = message.from.id
#   last = auction[:history].values.last.to_s
#   auction[:participants].map do |participant_id, participant_name|
#     if participant_id != last
#       bot.api.send_message(chat_id: participant_id, text: "#{participant_name}, Вы принимаете участие в аукционе по лоту:
#       \"#{auction[:name]}\".\n#{auction[:participants]["#{last}"].slice(0,3)}*** поднял цену до #{current_price}$.", reply_markup: keyboard(auction))
#     end
#   end
# end

# def remove_buttons(bot, message)
#   markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [])
#   bot.api.editMessageReplyMarkup(chat_id: message.message.chat.id, message_id: message.message.message_id, reply_markup: markup)
# end

# Telegram::Bot::Client.run(token) do |bot|
#   bot.listen do |message|
#     case message
#     when Telegram::Bot::Types::CallbackQuery
#       # Here you can handle your callbacks from inline buttons
#       if message.data == 'participate'
#         auction[:participants]["#{message.from.id}"] = "#{message.from.first_name} #{message.from.last_name}"
#         auction_message(bot, message, auction)
#       end
#       if message.data == 'bet'
#         auction[:current_price]+=auction[:bet]
#         remove_buttons(bot, message)
#         bot.api.send_message(chat_id: message.from.id, text: "#{message.from.first_name}, Вы подняли цену до #{auction[:current_price]}$")
#         auction_update(bot, message, auction)
#       end
#       if message.data == 'price'
#         markup=Telegram::Bot::Types::ForceReply.new(force_reply: true)
#         bot.api.send_message(chat_id: message.from.id, text: 'Введите свою цену', reply_markup: markup)
#         @message = message
#         #binding.pry
#       end
#     when Telegram::Bot::Types::Message
#       unless message.reply_to_message.nil?
#         price = message.text.to_f
#         if price > auction[:current_price]
#           auction[:current_price]=price
#           bot.api.send_message(chat_id: message.from.id, text: "#{message.from.first_name}, Вы подняли цену до #{auction[:current_price]}$")
#           remove_buttons(bot, @message)
#           auction_update(bot, message, auction)
#         else bot.api.send_message(chat_id: message.from.id, text: "#{message.from.first_name}, ты чё ахуел?")
#         end
#       end
#       if message.text == '/auction'
#         kb = [
#           Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Зарегистрироваться!', url: 'http://t.me/SkayBU_bot'),
#           Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Участвовать в аукционе!', callback_data: 'participate')
#         ]
#         markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
#         bot.api.send_message(chat_id: message.chat.id, text: "#{auction[:name]}\n Начальная цена аукциона: #{auction[:start_price]}$", reply_markup: markup)
#         bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new(auction[:image], 'image/jpeg'))
#       end
#       if message.text == '/start'
#         bot.api.send_message(chat_id: message.from.id, text: "Добро пожаловать в комнату аукционов Skay BU, #{message.from.first_name}")
#       end
#       if message.text == '/stop'
#         bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
#       end
#       if message.text == '/history'
#         bot.api.send_message(chat_id: message.from.id, text: "#{auction[:history]}")
#       end
#       if message.text == '/participants'
#         bot.api.send_message(chat_id: message.from.id, text: "#{auction[:participants]}")
#       end
#       if message.text == '/end'
#         auction[:participants].map do |participant_id, participant_name|
#           bot.api.send_message(chat_id: participant_id, text: "#{participant_name}, торги по лоту: \"#{auction[:name]}\" окончены.\nПобедила ставка: #{auction[:current_price]}$.")
#         end
#       end
#     end
#   end
# end
