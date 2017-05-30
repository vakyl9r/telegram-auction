module Reports
  module Render
    class AllMessagesReport < Base
      private

      def generate(csv)
        csv << first_header
        csv << second_header

        @report.values.each do |user_result|
          csv << Array.new(5, nil)
          csv << user_row(user_result)

          user_result[:messages].each do |message_row|
            csv << message_row
          end
        end
      end

      def first_header
        [
          I18n.t('views.reports.all_messages_header.user'),
          I18n.t('views.reports.all_messages_header.phone_number'),
          I18n.t('views.reports.all_messages_header.keyword'),
          nil,
          nil
        ]
      end

      def second_header
        [
          I18n.t('views.reports.all_messages_header.created_at'),
          I18n.t('views.reports.all_messages_header.sender'),
          I18n.t('views.reports.all_messages_header.message'),
          I18n.t('views.reports.all_messages_header.rule'),
          I18n.t('views.reports.all_messages_header.exception')
        ]
      end

      def user_row(row)
        [
          row[:user],
          row[:phone_number],
          row[:keyword],
          nil,
          nil
        ]
      end
    end
  end
end
