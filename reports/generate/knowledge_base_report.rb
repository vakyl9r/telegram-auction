require './app/domain/reports/generate/all_messages_report'

module Reports
  class Generate
    class KnowledgeBaseReport < AllMessagesReport
      def perform
        @number_of_events = 0
        @number_of_users = 0
        @knowledges = Set.new

        super.merge(knowledge_base_stats)
      end

      private

      def knowledge_base_stats
        {
          number_of_responses: @knowledges.size,
          number_of_events: @number_of_events,
          number_of_users: @number_of_users
        }
      end

      def average_events_per_user
        number_of_users = @users.count
        number_of_users.zero? ? 0 : (@number_of_events / number_of_users.to_f)
      end

      def user_result(user)
        keyword = user.keyword_rel_by_coach(@coach)&.keyword
        messages = filtered_user_messages(user)
        return unless keyword && messages.count.positive?

        @number_of_users += 1
        @number_of_events += messages.size

        messages.map do |message|
          @knowledges.add(message.knowledge_base_id)
          message_row(user, message)
        end
      end

      def message_row(user, message)
        [
          message.knowledge_base.phrase,
          message.body,
          user.phone_number,
          message.updated_at
        ]
      end

      def filtered_user_messages(user)
        messages = user.messages.includes(:knowledge_base)
                       .where(coach: @coach)
                       .where.not(knowledge_base: nil)
                       .order(:created_at)

        apply_created_at_filters(messages, user.time_zone)
      end
    end
  end
end
