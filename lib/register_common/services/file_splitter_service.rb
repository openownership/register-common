# frozen_string_literal: true

require 'stringio'
require 'tmpdir'
require 'register_common/compressors/gzip_writer'

module RegisterCommon
  module Services
    class FileSplitterService
      DEFAULT_LINES_PER_FILE = 2_500_000

      def initialize(writer: Compressors::GzipWriter.new)
        @writer = writer
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def split_stream(stream, split_size: DEFAULT_LINES_PER_FILE, max_lines: nil)
        file_index = 0

        Dir.mktmpdir do |dir|
          file_path = File.join(dir, "file-#{file_index}")
          current_file = writer.open_stream(StringIO.new)
          current_row_count = 0
          total_row_count = 0

          stream.each do |line|
            # Write line to open file
            current_file << line

            # Increment row count
            current_row_count += 1
            total_row_count += 1

            # Check whether our target of lines is met
            next unless (current_row_count >= split_size) || (max_lines && (total_row_count >= max_lines))

            # Since line count target exceeded close file and yield to user
            result = writer.close_stream(current_file)
            File.binwrite(file_path, result)
            yield file_path

            # Remove file once processed
            File.delete file_path

            # Open new file ready for next lines
            file_index += 1
            file_path = File.join(dir, "file-#{file_index}")
            current_file = writer.open_stream(StringIO.new)
            current_row_count = 0

            break if max_lines && (total_row_count >= max_lines)
          end

          result = writer.close_stream(current_file)
          File.binwrite(file_path, result)
          if current_row_count.positive?
            yield file_path
            file_index += 1
          end
        end

        file_index
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      attr_reader :writer
    end
  end
end
