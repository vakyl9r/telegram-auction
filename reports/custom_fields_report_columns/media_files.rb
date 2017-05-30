module Reports
  module CustomFieldsReportColumns
    class MediaFiles < Base
      def self.available(coach, language)
        MediaFilesQuery.new(coach, language).all.pluck(:id, :name).map do |id, name|
          [id.to_s, name]
        end.to_h
      end

      private

      def results_for_user(_user)
        @_result ||= MediaFile.where(coach: @coach).where(id: @fields).map { |f| f.file.url }
      end
    end
  end
end
