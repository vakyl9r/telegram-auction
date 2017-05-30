module Reports
  module CustomFieldsReportColumns
    class CustomMacros < Base
      def self.available(_coach, _language)
        Macros::Custom.names_of_available_macros_for_report.map do |name|
          [name.downcase, name]
        end.to_h
      end

      private

      def results_for_user(user)
        Macros::Value.new(@coach, user).fields(@fields.map(&:upcase)).values
      end
    end
  end
end
