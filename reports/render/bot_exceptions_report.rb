module Reports
  module Render
    class BotExceptionsReport < Base
      private

      def generate(csv)
        csv << header
        @report.values.each do |message_rows|
          message_rows.each do |message_row|
            csv << message_row
          end
        end
      end

      def header
        [
          I18n.t('views.reports.bot_exceptions_header.script_rule'),
          I18n.t('views.reports.bot_exceptions_header.user_response'),
          I18n.t('views.reports.bot_exceptions_header.user_phone_number'),
          I18n.t('views.reports.bot_exceptions_header.datetime_of_exception')
        ]
      end
    end
  end
end
