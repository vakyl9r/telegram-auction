module Reports
  module CustomFieldsReportColumns
    class Predicates < Base
      def self.available(_coach, _language)
        { 'days_on_program' => 'Days On Program',
          'register_date' => 'Register Date' }
      end

      private

      def results_for_user(user)
        @fields.map do |field|
          next unless field.in? self.class.available(nil, nil).keys
          send(field.to_sym, user)
        end
      end

      def days_on_program(user)
        user_activity = user.activities.find_by(coach: @coach)
        return nil unless user_activity
        user_activity.day_on_program - 1
      end

      def register_date(user)
        return nil unless user.keyword_rel_by_coach(@coach)
        Time.use_zone(user.time_zone) do
          user.keyword_rel_by_coach(@coach).created_at.to_date
        end
      end
    end
  end
end
