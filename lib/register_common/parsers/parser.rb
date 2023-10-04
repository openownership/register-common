# frozen_string_literal: true

require_relative 'csv_reader'
require_relative 'file_formats'
require_relative 'json_reader'
require_relative 'plain_reader'

module RegisterCommon
  module Parsers
    class Parser
      def initialize(
        csv_reader: CsvReader.new,
        json_reader: JsonReader.new,
        plain_reader: PlainReader.new
      )
        @csv_reader = csv_reader
        @json_reader = json_reader
        @plain_reader = plain_reader
      end

      def foreach(stream, file_format: FileFormats::PLAIN, &block)
        select_reader(file_format).foreach(stream, &block)
      end

      private

      attr_reader :csv_reader, :json_reader, :plain_reader

      def select_reader(file_format)
        case file_format
        when FileFormats::PLAIN
          plain_reader
        when FileFormats::JSON
          json_reader
        when FileFormats::CSV
          csv_reader
        else
          raise UnknownFileFormatError
        end
      end
    end
  end
end
