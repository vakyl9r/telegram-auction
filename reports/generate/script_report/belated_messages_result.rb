module Reports
  class Generate
    class ScriptReport
      class BelatedMessagesResult
        include DateFilters
        def initialize(rule, users, options = {})
          @rule = rule
          @users = users
          @options = options
        end

        def render
          {
            received: belated_messages_ids.count,
            messages: messages_with_counts
          }
        end

        private

        attr_reader :rule

        def belated_messages_ids
          @_belated_messages ||= current_rule_messages.map do |message|
            next_message = next_message_after(message)
            next_message.id if next_message.present? && belated?(next_message)
          end.compact
        end

        def current_rule_messages
          rule_messages_to_user = rule.messages
                                      .where(status: :delivered)
                                      .where(profiles_user_id: @users)
          apply_date_filters(rule_messages_to_user)
        end

        def next_message_after(message)
          Message.where(coach_id: message.coach_id,
                        profiles_user_id: message.profiles_user_id,
                        status: :received)
                 .where('id > ?', message.id)
                 .order(id: :asc)
                 .limit(1).first
        end

        def belated?(message)
          !message.bot && rule_suitable?(message.rule)
        end

        def rule_suitable?(message_rule)
          message_rule.blank? ||
            (message_rule.id != rule.id && !message_rule.requires_user_response?)
        end

        def messages_with_counts
          return {} if belated_messages_ids.empty?
          result = Message.where(id: belated_messages_ids)
                          .group(:body)
                          .order('count_body desc')

          result = apply_date_filters(result)

          result.count(:body)
        end
      end
    end
  end
end
