module Reports
  class MonthlyStats
    def initialize(coach, year, month, language)
      @coach = coach
      @year = year
      @month = month
      @language = language
      @end_of_month = DateTime.new(year.to_i, month.to_i, 1).end_of_month
    end

    def render
      {
        label: I18n.l(@end_of_month.to_date, format: :statistics_interim),
        new_users: new_users_count,
        active_users: active_users_count,
        unsubscribed_users: unsubscribed_users_count,
        total_users: total_users_count
      }
    end

    private

    attr_reader :year, :month, :end_of_month

    def new_users_count
      zero_for_future_month ||
        activities.where(
          "DATE_PART('YEAR', start_program_at) = ? AND " \
          "DATE_PART('MONTH', start_program_at) = ?",
          year, month
        ).count
    end

    def active_users_count
      zero_for_future_month ||
        activities.where('start_program_at <= ?', end_of_month)
                  .where('finished_at IS NULL OR finished_at > ?', end_of_month)
                  .count
    end

    def unsubscribed_users_count
      zero_for_future_month ||
        activities.where(
          "DATE_PART('YEAR', finished_at) = ? AND " \
          "DATE_PART('MONTH', finished_at) = ?",
          year, month
        ).count
    end

    def total_users_count
      zero_for_future_month ||
        activities.where('start_program_at <= ?', end_of_month).count
    end

    def activities
      @_activities ||= UserActivity.joins(:keyword).where(
        coach: @coach, keywords: { customer_id: @coach.customer_id }, language: @language
      )
    end

    def zero_for_future_month
      0 if future_month?
    end

    def future_month?
      @_future_month ||= Time.new(year.to_i, month.to_i).future?
    end
  end
end
