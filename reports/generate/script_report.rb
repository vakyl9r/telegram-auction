require './app/domain/reports/generate/base'

module Reports
  class Generate
    class ScriptReport < Base
      def perform
        { rules: rules_result }
      end

      private

      def rules_result
        rules_query.includes(:alternate_scripts).map do |rule|
          RowResult.new(rule, @users, message_filter).render
        end
      end

      def rules_query
        @coach.rules.where(id: selected_rules).order(:code)
      end

      def message_filter
        @template[:message_filter] || {}
      end

      def rules_filter
        @template[:rules_filter] || {}
      end

      def selected_rules
        rules_filter[:rules] || {}
      end
    end
  end
end
