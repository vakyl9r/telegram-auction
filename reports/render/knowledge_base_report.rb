module Reports
  module Render
    class KnowledgeBaseReport < Base
      private

      def generate(csv)
        generate_stats(csv)
        csv << header
        @report.values.each do |message_rows|
          message_rows.each do |message_row|
            csv << message_row
          end
        end
      end

      def generate_stats(csv)
        %i(number_of_responses number_of_events number_of_users).each do |field|
          csv << [stats_field(field)]
        end
      end

      def stats_field(key)
        I18n.t(key, scope: 'views.reports.knowledge_base_stats', number: @report.delete(key))
      end

      def header
        [
          I18n.t('views.reports.knowledge_base_header.knowledge_base_label'),
          I18n.t('views.reports.knowledge_base_header.user_phrase'),
          I18n.t('views.reports.knowledge_base_header.user_phone_number'),
          I18n.t('views.reports.knowledge_base_header.datetime_of_exception')
        ]
      end
    end
  end
end
