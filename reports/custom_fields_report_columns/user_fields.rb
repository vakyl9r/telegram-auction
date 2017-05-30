module Reports
  module CustomFieldsReportColumns
    class UserFields < Base
      def self.available(_coach, _language)
        RuleExecution::Action::SetUserField.available.keys.map do |field|
          [field.downcase, field]
        end.to_h
      end

      private

      def results_for_user(user)
        @fields.map do |field|
          if field == 'confirmed_smartphone'
            human_boolean(user.send(field))
          else
            user.public_send(field)
          end
        end
      end

      def human_boolean(boolean)
        boolean ? 'Yes' : 'No'
      end
    end
  end
end
