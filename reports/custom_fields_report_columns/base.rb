module Reports
  module CustomFieldsReportColumns
    class Base
      include BatchIterator
      class InterfaceNotImplementedError < NoMethodError; end

      # users - an Profiles::User::ActiveRecord_Relation with users
      # coach - a Coach instance
      # fields - Array of the field keys in String type
      def initialize(users, coach, fields)
        @users = users
        @coach = coach
        @fields = fields
      end

      def build
        result = {}
        each_batch(@users) do |user|
          result[user.id] = results_for_user(user)
        end
        result
      end

      def self.available(_coach, _language)
        raise InterfaceNotImplementedError, 'Implement this method in a child class'
      end
    end
  end
end
