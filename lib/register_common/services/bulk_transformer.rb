# frozen_string_literal: true

require 'register_common/services/file_reader'

require_relative 'msg_handler'

module RegisterCommon
  module Services
    class BulkTransformer
      BATCH_SIZE = 25
      DEFAULT_PARALLEL_FILES = 1
      NAMESPACE = 'BULK_TRANSFORMER'

      # rubocop:disable Metrics/ParameterLists
      def initialize(s3_adapter:, s3_bucket:, set_client:, file_reader: nil, batch_size: nil, namespace: nil)
        @s3_adapter = s3_adapter
        @s3_bucket = s3_bucket
        @set_client = set_client
        @file_reader = file_reader || RegisterCommon::Services::FileReader.new(
          s3_adapter:,
          batch_size: (batch_size || BATCH_SIZE)
        )
        @msg_handler = MsgHandler.new(s3_adapter:, s3_bucket:)
        @namespace = namespace || NAMESPACE
      end
      # rubocop:enable Metrics/ParameterLists

      def call(s3_prefix, parallel_files: nil, &block)
        processed_files = set_client.init_set("#{@namespace}:#{s3_prefix}")

        s3_paths = s3_adapter.list_objects(s3_bucket:, s3_prefix:)

        s3_paths.each_slice(parallel_files || DEFAULT_PARALLEL_FILES) do |s3_paths_batch|
          threads = []

          s3_paths_batch.each do |s3_path|
            next if processed_files.contains?(s3_path)

            threads << Thread.new do
              process_s3_path(s3_path, &block)

              processed_files.add(s3_path)
            end
          end

          threads.each(&:join)
        end
      end

      private

      attr_reader :file_reader, :s3_adapter, :s3_bucket, :msg_handler, :set_client

      def process_s3_path(s3_path)
        file_reader.read_from_s3(s3_bucket:, s3_path:) do |rows|
          yield rows.map { |row| msg_handler.process row }
        end
      end
    end
  end
end
