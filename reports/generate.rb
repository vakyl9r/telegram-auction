module Reports
  class Generate
    PREVIEW_LIMIT = 10
    AVAILABLE = %w(
      custom_fields_report all_messages_report detailed_messages_report
      bot_exceptions_report script_report billing_report knowledge_base_report
    ).freeze
    USER_ACTIVITY_DATE_FILTERS = {
      start_program_date_from: ['>=', :start_program_at],
      start_program_date_to: ['<=', :start_program_at],
      finished_date_from: ['>=', :finished_at],
      finished_date_to: ['<=', :finished_at]
    }.freeze

    class UnknownReportType < ArgumentError; end

    def initialize(coach, report_type, template, language)
      raise(
        UnknownReportType,
        "Report type #{report_type} is not supported"
      ) unless report_type.in? AVAILABLE
      @coach = coach
      @report_type = report_type
      @template = template
      @language = language
    end

    def perform(preview: false)
      return unless @coach
      users = filtered_users.order(:id)
      users = users.limit(PREVIEW_LIMIT) if preview
      report_type_class.new(users, @coach, @template, @language).perform
    end

    private

    def report_type_class
      "Reports::Generate::#{@report_type.camelize}".constantize
    end

    def users_filter
      @_users_filter ||= @template[:users_filter] || {}
    end

    def keywords
      return @_keywords if @_keywords
      @_keywords = KeywordsQuery.new(@coach, @language).all
      @_keywords = @_keywords.where(
        id: users_filter[:keyword_ids]
      ) if users_filter[:keyword_ids].present?
      @_keywords
    end

    def filtered_users
      return Profiles::User.none if keywords.blank?
      users = Profiles::User.includes(:user).joins(:user_keyword_relations)
                            .where(user_keyword_relations: { keyword_id: keywords })
      users = filter_by_status(users)
      filter_by_subscription_period(users)
    end

    def filter_by_status(users)
      scope = users.joins(user_keyword_relations: :user_activity)
      condition = { user_activities: { finished_at: nil } }
      scope = scope.where(condition) if users_filter[:status] == 'enabled'
      scope = scope.where.not(condition) if users_filter[:status] == 'disabled'
      scope
    end

    def filter_by_subscription_period(users)
      return users unless user_activity_date_filters_present?
      scope = filter_roughly_by_registration_period(users)
      matching_user_ids = scope.select do |user|
        activity = user.activities.find_by(coach: @coach)
        user_activity_matches_filters?(activity)
      end.map(&:id)
      scope.where(id: matching_user_ids)
    end

    def user_activity_date_filters_present?
      USER_ACTIVITY_DATE_FILTERS.any? { |filter, _| users_filter[filter].present? }
    end

    def user_activity_matches_filters?(activity)
      USER_ACTIVITY_DATE_FILTERS.all? do |filter, (op, attribute)|
        users_filter[filter].blank? ||
          activity.send(attribute).send(op, user_time(activity.profiles_user, users_filter[filter]))
      end
    end

    def filter_roughly_by_registration_period(users)
      scope = users.joins(user_keyword_relations: :user_activity)
      USER_ACTIVITY_DATE_FILTERS.each do |filter, (op, attribute)|
        scope = scope.where(
          "user_activities.#{attribute} #{op} ?",
          boundary_time_for(users_filter[filter], op)
        ) unless users_filter[filter].blank?
      end
      scope
    end

    def user_time(user, time_string)
      ActiveSupport::TimeZone[user.time_zone].parse(time_string)
    end

    def boundary_time_for(time, operation)
      Time.parse(time).send((operation == '>=' ? '-' : '+'), 1.day)
    end
  end
end
