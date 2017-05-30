require './app/domain/reports/generate/base'

module Reports
  class Generate
    class CustomFieldsReport < Base
      include BatchIterator

      def perform
        {
          columns: column_names,
          list: user_rows
        }
      end

      private

      def columns_class(name)
        Reports::CustomFieldsReportColumns.available[name]
      end

      def column_names
        ['Email', 'Phone Number'] + report_columns.map do |column_type, columns|
          next if columns.blank?
          columns.map do |name|
            columns_class(column_type).available(@coach, @language)[name]
          end
        end.compact.flatten
      end

      def user_rows
        rows = base_user_rows
        report_columns.each do |column_type, columns|
          results = columns_class(column_type).new(@users, @coach, columns).build
          results.each do |user_id, cells|
            rows[user_id] = rows[user_id] + cells
          end
        end
        rows
      end

      def report_columns
        @_report_columns ||= @template[:report_columns] || {}
      end

      def base_user_rows
        result = {}
        each_batch(@users.joins(:user).select(:id, :phone_number)) do |user|
          result[user.id] = [user.email, user.phone_number]
        end
        result
      end
    end
  end
end
