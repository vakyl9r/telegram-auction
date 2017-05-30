module Reports
  # Classes within this module implement logic behind columns of Custom Reports
  # (a type of Report based on a list of coaches' users). Each class returns a list
  # of column names it can build for the report and also generates values for these
  # columns for users.
  #
  # CustomFieldsReportColumns classes do not take part in user filtering.
  #
  # CustomFieldsReportColumns module itself provides a method to list available columns
  # classes:
  #
  #   CustomFieldsReportColumns.available => { custom_field: CustomFieldReportColumns::CustomFields,
  #                                      ... }
  module CustomFieldsReportColumns
    AVAILABLE = %i(custom_field user_field custom_macro variable media_file message predicate)

    def self.available
      AVAILABLE.map do |name|
        [name, "Reports::CustomFieldsReportColumns::#{name.to_s.pluralize.camelize}".constantize]
      end.to_h
    end
  end
end
