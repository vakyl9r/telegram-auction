require './app/domain/reports/generate/base'

module Reports
  class Generate
    class AllMessagesReport < Base
      def perform
        @users.map do |user|
          [user.id, user_result(user)]
        end.to_h.compact
      end

      private

      def user_result(user)
        keyword = user.keyword_rel_by_coach(@coach).try(:keyword)
        messages = filtered_user_messages(user)
        return unless keyword && messages.count > 0
        user_result_header(keyword, user).merge(
          messages: messages.map { |m| message_row(m) }
        )
      end

      def user_result_header(keyword, user)
        {
          user: user.user.full_name || user.phone_number,
          phone_number: user.phone_number,
          keyword: keyword.code
        }
      end

      def message_row(message)
        [
          message.created_at,
          message.sender,
          message.body,
          message.rule.try(:code),
          !message.bot?
        ]
      end

      def filtered_user_messages(user)
        messages = user.messages.includes(:rule).where(coach: @coach)
        apply_created_at_filters(messages, user.time_zone)
      end

      def apply_created_at_filters(messages, time_zone)
        result = messages
        { date_from: '>=', date_to: '<=' }.each do |filter, op|
          result = result.where(
            "created_at #{op} ?",
            ActiveSupport::TimeZone[time_zone].parse(@template[:message_filter][filter])
          ) unless @template.try(:[], :message_filter).try(:[], filter).blank?
        end
        result
      end
    end
  end
end
