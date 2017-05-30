module Reports
  module Render
    class BillingReport < Base
      private

      def generate(csv)
        csv << header
        @report.each do |row|
          csv << row.values
        end
      end

      def header
        report_headers = %w(
          keyword registration_date name phone_number status disabled_at last_rule
        )
        report_headers.map do |report_header|
          I18n.t("views.reports.billing_report_header.#{report_header}")
        end
      end
    end
  end
end
