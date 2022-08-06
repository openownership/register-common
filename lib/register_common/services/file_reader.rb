require 'tmpdir'
require 'register_common/decompressors/decompressor'
require 'register_common/parsers/parser'

module RegisterCommon
  module Services
    class FileReader
      BATCH_SIZE = 100
      DEFAULT_FORMAT = Parsers::FileFormats::PLAIN
      DEFAULT_COMPRESSION = Decompressors::CompressionTypes::NONE

      def initialize(
        s3_adapter:,
        decompressor: nil,
        parser: nil,
        batch_size: BATCH_SIZE
      )
        @decompressor = decompressor || Decompressors::Decompressor.new
        @parser = parser || Parsers::Parser.new
        @s3_adapter = s3_adapter
        @batch_size = batch_size
      end

      def read_from_s3(s3_bucket:, s3_path:, file_format: DEFAULT_FORMAT, compression: DEFAULT_COMPRESSION, &block)
        Dir.mktmpdir do |dir|
          file_path = File.join(dir, "tmpfile")
          s3_adapter.download_from_s3(s3_bucket: s3_bucket, s3_path: s3_path, local_path: file_path)
          read_from_local_path(file_path, file_format: file_format, compression: compression, &block)
        end
      end

      def read_from_local_path(file_path, file_format: DEFAULT_FORMAT, compression: DEFAULT_COMPRESSION, &block)
        File.open(file_path, 'r') do |stream|
          read_from_stream(stream, file_format: file_format, compression: compression, &block)
        end
      end

      def read_from_stream(stream, file_format: DEFAULT_FORMAT, compression: DEFAULT_COMPRESSION)
        batch_records = []

        with_deflated_stream(stream, compression: compression) do |deflated|
          parser.foreach(stream, file_format: file_format) do |record|
            batch_records << record
            next unless (batch_records.length >= batch_size)
            yield batch_records
            batch_records = []
          end  
        end

        unless batch_records.empty?
          yield batch_records
        end
      end

      private

      attr_reader :s3_adapter, :parser, :decompressor, :batch_size
    end
  end
end
