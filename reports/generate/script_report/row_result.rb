module Reports
  class Generate
    class ScriptReport
      class RowResult
        def initialize(rule, users, options = {})
          @rule = rule
          @users = users
          @options = options
        end

        def render
          if looking_forward?
            sequential_result
          else
            current_rule_result
          end
        end

        private

        attr_reader :rule

        def looking_forward?
          @options[:looking_forward] == '1' && rule.requires_user_response?
        end

        def current_rule_result
          RuleResult.new(rule, @users, @options).render
        end

        def next_rule_result
          BelatedMessagesResult.new(rule, @users, @options).render
        end

        def sequential_result
          merge_results(current_rule_result, next_rule_result)
        end

        def merge_results(primary, secondary)
          {
            code: primary[:code],
            script: primary[:script],
            delivered: primary[:delivered],
            received: "#{primary[:received]} (#{secondary[:received]})",
            messages: primary[:messages],
            belated_messages: secondary[:messages]
          }
        end
      end
    end
  end
end
