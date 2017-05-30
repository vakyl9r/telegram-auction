module Reports
  module Render
    class CustomFieldsReport < Base
      private

      def generate(csv)
        csv << @report[:columns]
        @report[:list].values.each do |item|
          csv << item
        end
      end
    end
  end
end
