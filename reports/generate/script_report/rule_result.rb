module Reports
  class Generate
    class ScriptReport
      class RuleResult
        include DateFilters
        def initialize(rule, users, options = {})
          @rule = rule
          @users = users
          @options = options
        end

        def render
          {
            code: rule.code,
            script: Reports::RuleCarrier.new(rule).script_name,
            delivered: delivered_messages_count,
            received: received_messages_count,
            messages: rule_messages_with_counts
          }
        end

        private

        attr_reader :rule

        def delivered_messages_count
          messages_count_query.where(status: :delivered).count
        end

        def received_messages_count
          return unless rule.requires_user_response?
          messages_count_query.where(status: :received).count
        end

        def messages_count_query
          rule_messages_for_user = rule.messages.where(profiles_user_id: @users)
          apply_date_filters(rule_messages_for_user)
        end

        def rule_messages_with_counts
          return {} unless rule.requires_user_response?
          result = rule.messages
                       .where(status: :received)
                       .where(profiles_user_id: @users)
                       .group(:body)
                       .order('count_body desc')

          result = apply_date_filters(result)
          result.count(:body)
        end
      end
    end
  end
end
