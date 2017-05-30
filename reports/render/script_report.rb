module Reports
  module Render
    class ScriptReport < Base
      private

      def generate(csv)
        csv << script_report_header
        @report[:rules].each do |row|
          csv << script_report_row(row)
        end
      end

      def script_report_header
        [
          I18n.t('views.reports.script_report_header.code'),
          I18n.t('views.reports.script_report_header.script'),
          I18n.t('views.reports.script_report_header.delivered'),
          received_header,
          responses_header
        ]
      end

      def received_header
        if looking_forward?
          I18n.t('views.reports.script_report_header.responded') +
            " | #{I18n.t('views.reports.script_report_header.late_responses')}"
        else
          I18n.t('views.reports.script_report_header.responded')
        end
      end

      def responses_header
        if looking_forward?
          I18n.t('views.reports.script_report_header.responses') +
            " (#{I18n.t('views.reports.script_report_header.late_responses')})"
        else
          I18n.t('views.reports.script_report_header.responses')
        end
      end

      def script_report_row(row)
        [row[:code],
         row[:script],
         row[:delivered],
         row[:received],
         messages_summary(row)]
      end

      def messages_summary(row)
        result = join_messages(row[:messages])
        if row[:belated_messages].present?
          result += "\n---\n"
          result += join_messages(row[:belated_messages])
        end
        result
      end

      def join_messages(messages)
        messages.map { |body, count| "#{count}: #{body}" }.join("\n")
      end

      def looking_forward?
        return false if @report[:rules].empty?
        !@report[:rules].first.dig(:belated_messages).nil?
      end
    end
  end
end
