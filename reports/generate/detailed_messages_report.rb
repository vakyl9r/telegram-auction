require './app/domain/reports/generate/base'

module Reports
  class Generate
    class DetailedMessagesReport < Base
      def perform
        {
          users: users_with_messages.map { |user| user_header(user) }.to_h,
          rules: rules.map { |rule| rule_result(rule) }
        }
      end

      private

      def users_with_messages
        @_users_with_messages = @users.select(&method(:user_has_messages?))
      end

      def user_header(user)
        [
          user.phone_number,
          user.created_at.utc
        ]
      end

      def rule_result(rule)
        [
          rule.code,
          rule.alternate_scripts.first&.body,
          users_with_messages.map do |user|
            message = last_message_responding_to_rule(user, rule)
            received_message_body = message&.status == 'received' ? message.body : nil
            message ? received_message_body : '-'
          end
        ]
      end

      def last_message_responding_to_rule(user, rule)
        messages = user.messages
                       .order(:created_at)
                       .where(rule: rule, status: :received)
        messages = user.messages
                       .order(:created_at)
                       .where(rule: rule, status: :delivered) if messages.empty?
        apply_created_at_filters(messages, user.time_zone).last
      end

      def user_has_messages?(user)
        last_message_responding_to_rule(user, rules).present?
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

      def rules
        @_rules ||= RulesQuery.new(@coach, @language)
                              .all.order(:code).includes(:alternate_scripts)
      end
    end
  end
end
