require 'csv'

module RegisterCommon
  module Parsers
    class CsvReader
      def foreach(stream, headers: true, &block)
        csv = CSV.new(stream, headers: headers)
        csv.each { |row| yield row.to_h }
      end
    end
  end
end
