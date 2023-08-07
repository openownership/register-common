# frozen_string_literal: true

require 'csv'

module RegisterCommon
  module Parsers
    class CsvReader
      def foreach(stream, headers: true)
        csv = CSV.new(stream, headers:)
        csv.each { |row| yield row.to_h }
      end
    end
  end
end
