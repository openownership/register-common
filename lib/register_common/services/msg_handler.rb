require 'json'

module RegisterCommon
  module Services
    class MsgHandler
      def initialize(s3_adapter:, s3_bucket:)
        @s3_adapter = s3_adapter
        @s3_bucket = s3_bucket
      end

      def process(data)
        parsed = JSON.parse(data)
        if parsed['s3_path']
          return s3_adapter.download_and_read(s3_bucket: s3_bucket, s3_path: parsed['s3_path'])
        end
        data
      rescue JSON::ParserError
        data
      end

      private

      attr_reader :s3_adapter, :s3_bucket
    end
  end
end
