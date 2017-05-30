module Reports
  module CustomFieldsReportColumns
    class Messages < Base
      def self.available(_coach, _language)
        {
          'count' => 'Message Count'
        }
      end

      def build
        load_counts if @fields.include? 'count'
        super
      end

      private

      def load_counts
        @counts = Message.select('profiles_user_id user_id, COUNT(*) count')
                         .where(profiles_user_id: @users.pluck(:id), coach: @coach)
                         .group(:profiles_user_id)
                         .map { |row| [row.user_id, row.count] }.to_h
      end

      def results_for_user(user)
        @fields.map do |field|
          next unless field == 'count'
          @counts[user.id].to_i
        end
      end
    end
  end
end
