module Reports
  class Generate
    class ScriptReport
      module DateFilters
        def apply_date_filters(result)
          result = result.where('created_at >= ?', date_from) if date_from.present?
          result = result.where('created_at <= ?', date_to)   if date_to.present?
          result
        end

        def date_from
          @options[:date_from]
        end

        def date_to
          @options[:date_to]
        end
      end
    end
  end
end
