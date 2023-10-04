# frozen_string_literal: true

require_relative 'compression_types'
require_relative 'gzip_reader'
require_relative 'zip_reader'

module RegisterCommon
  module Decompressors
    class Decompressor
      def initialize(
        gzip_reader: GzipReader.new,
        zip_reader: ZipReader.new
      )
        @gzip_reader = gzip_reader
        @zip_reader = zip_reader
      end

      def with_deflated_stream(stream, compression:, &block)
        case compression
        when CompressionTypes::NONE
          block.call stream
        when CompressionTypes::GZIP
          gzip_reader.open_stream(stream, &block)
        when CompressionTypes::ZIP
          zip_reader.open_stream(stream, &block)
        else
          raise UnknownCompressionTypeError
        end
      end

      private

      attr_reader :gzip_reader, :zip_reader
    end
  end
end
