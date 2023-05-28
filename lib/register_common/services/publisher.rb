# frozen_string_literal: true

require 'stringio'
require 'json'
require 'xxhash'

require 'register_common/utils/mixins/retry_with_backoff'

module RegisterCommon
  module Services
    class Publisher
      include Utils::Mixins::RetryWithBackoff

      MsgUnsendable = Class.new(StandardError)

      DEFAULT_BUFFER_SIZE = 20
      MAX_BUFFER_BYTES = 1_000_000

      def initialize(
        stream_name:,
        kinesis_adapter:,
        buffer_size:,
        s3_adapter: nil,
        s3_prefix: nil,
        s3_bucket: nil,
        serializer: nil
      )
        @stream_name = stream_name
        @kinesis_adapter = kinesis_adapter
        @s3_adapter = s3_adapter
        @s3_prefix = s3_prefix
        @s3_bucket = s3_bucket
        @buffer_size = buffer_size
        @serializer = serializer
        @buffer = []
      end

      def publish(msg)
        unless msg.is_a? String
          msg = serializer ? serializer.serialize(msg) : msg.serialize
        end

        msg += "\n" if msg[-1] != "\n"

        # Handle case where buffer would be too large
        flush_buffer if (buffer.sum(&:length) + msg.length) >= MAX_BUFFER_BYTES

        # Handle case where single message is too large
        if msg.length >= MAX_BUFFER_BYTES
          send_large_msg msg
        # Add message to buffer
        else
          @buffer = buffer + [msg]

          return false unless buffer.length >= buffer_size

          flush_buffer
        end

        true
      end

      def finalize
        flush_buffer
        true
      end

      private

      attr_reader :buffer, :buffer_size, :stream_name, :retrier, :serializer, :kinesis_adapter, :s3_adapter,
                  :s3_bucket, :s3_prefix

      def flush_buffer
        return if buffer.empty?

        retry_with_backoff do
          kinesis_adapter.put_records(stream_name:, records: buffer)
        end

        @buffer = []
      end

      def send_large_msg(msg)
        msg_hash = XXhash.xxh64(msg).to_s

        s3_path = File.join(s3_prefix, msg_hash)

        unless s3_adapter.exists?(s3_bucket:, s3_path:)
          stream = StringIO.new(msg)
          s3_adapter.upload_from_file_obj_to_s3(s3_bucket:, s3_path:, stream:)
        end

        retry_with_backoff do
          kinesis_adapter.put_records(
            stream_name:,
            records: [
              "#{{ s3_path: }.to_json}\n"
            ]
          )
        end
      end
    end
  end
end
