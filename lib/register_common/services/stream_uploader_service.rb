# frozen_string_literal: true

require 'register_common/services/file_splitter_service'

module RegisterCommon
  module Services
    class StreamUploaderService
      DEFAULT_LINES_PER_FILE = 2_500_000
      MAX_PARTS = 98

      def initialize(
        s3_adapter:,
        file_splitter_service: Services::FileSplitterService.new,
        max_parts: MAX_PARTS
      )
        @s3_adapter = s3_adapter
        @file_splitter_service = file_splitter_service
        @max_parts = max_parts
      end

      def upload_in_parts(stream, s3_bucket:, s3_prefix:, split_size: DEFAULT_LINES_PER_FILE, max_lines: nil)
        file_index = 0
        file_splitter_service.split_stream(
          stream,
          split_size:,
          max_lines:,
        ) do |split_file_path|
          part = part_for_file_index file_index
          s3_path = File.join(s3_prefix, "part=part#{part}", "file-#{file_index}.csv.gz")
          s3_adapter.upload_to_s3(s3_bucket:, s3_path:, local_path: split_file_path)
          file_index += 1
        end

        file_index
      end

      private

      attr_reader :s3_adapter, :file_splitter_service, :max_parts

      def part_for_file_index(file_index)
        file_index % max_parts
      end
    end
  end
end
