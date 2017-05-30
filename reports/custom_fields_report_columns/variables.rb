module Reports
  module CustomFieldsReportColumns
    class Variables < Base
      def self.available(coach, language)
        Variable.compiled_with_system(coach, language)
                .order(:id).pluck(:id, :variable)
                .map { |id, variable| [id.to_s, variable] }.to_h
      end

      private

      def results_for_user(_user)
        @_result ||= Variable.compiled_with_system_by_coach(@coach)
                             .where(id: @fields)
                             .map(&method(:variable_variants_to_string))
      end

      def variable_variants_to_string(variable)
        variable.variable_variations.map(&:value).join(' - ')
      end
    end
  end
end
