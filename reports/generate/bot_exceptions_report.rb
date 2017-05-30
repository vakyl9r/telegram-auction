require './app/domain/reports/generate/all_messages_report'

module Reports
  class Generate
    class BotExceptionsReport < AllMessagesReport
      private

      def user_result(user)
        keyword = user.keyword_rel_by_coach(@coach).try(:keyword)
        messages = filtered_user_messages(user)
        return unless keyword && messages.count > 0
        messages.map { |m| message_row(user, m) }
      end

      def message_row(user, message)
        [
          message.rule.try(:code),
          message.body,
          user.phone_number,
          message.updated_at
        ]
      end

      def filtered_user_messages(user)
        messages = user.messages.includes(:rule).where(coach: @coach, bot: false)
                       .order(:created_at)
                       .where('properties @> hstore(?, ?)', 'sender', 'user')
        apply_created_at_filters(messages, user.time_zone)
      end
    end
  end
end
