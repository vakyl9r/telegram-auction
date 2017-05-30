module Reports
  module Render
    class DetailedMessagesReport < Base
      private

      def generate(csv)
        csv << user_phones_header
        csv << user_created_at_header
        @report[:rules].each do |row|
          csv << row.flatten
        end
      end

      def user_phones_header
        [nil, nil] + @report[:users].keys
      end

      def user_created_at_header
        [nil, nil] + @report[:users].values
      end
    end
  end
end
