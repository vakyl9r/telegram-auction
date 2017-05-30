module Reports
  module CustomFieldsReportColumns
    class CustomFields < Base
      def self.available(coach, _language)
        coach.custom_fields.pluck(:id, :field_name).map do |id, field_name|
          [id.to_s, field_name]
        end.to_h
      end

      private

      def results_for_user(user)
        values = field_values_for_user(user)
        @fields.map do |field_id|
          values[field_id]
        end
      end

      def field_values_for_user(user)
        user.user_field_values.joins(:custom_field)
            .select(:custom_field_id, :field_type, :value)
            .where(custom_field_id: @fields).map do |value_record|
          [
            value_record.custom_field_id.to_s,
            parse_value(value_record, user)
          ]
        end.to_h
      end

      def parse_value(value_record, user)
        FieldType[value_record.field_type.to_sym].parse(
          value_record.value, user
        )
      rescue
        nil
      end
    end
  end
end
