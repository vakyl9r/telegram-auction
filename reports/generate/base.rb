module Reports
  class Generate
    class Base
      def initialize(users, coach, template, language)
        @users = users
        @coach = coach
        @template = template
        @language = language
      end
    end
  end
end
