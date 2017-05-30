require 'csv'

module Reports
  module Render
    class Base
      def initialize(report)
        @report = report
      end

      def perform
        CSV.generate do |csv|
          generate(csv)
        end
      end
    end
  end
end
