require './app/domain/reports/generate/base'

module Reports
  class Generate
    class BillingReport < Base
      def perform
        @users.map do |user|
          user_result(user)
        end
      end

      private

      def user_result(user)
        activity = user.activities.find_by(coach: @coach)
        user_row(user, activity)
      end

      def user_row(user, activity)
        {
          keyword: activity.keyword.code,
          registration_date: format_date(activity.start_program_at),
          name: user.full_name,
          phone_number: user.phone_number,
          status: activity.finished_at? ? 'disabled' : 'enabled',
          disabled_at: format_date(activity.finished_at),
          last_rule: last_rule(user).try(:code)
        }
      end

      def format_date(date)
        I18n.l(date, format: :billing_report) if date
      end

      def last_rule(user)
        user.messages.where(coach_id: @coach).where.not(rule: nil).last.try(:rule)
      end
    end
  end
end
