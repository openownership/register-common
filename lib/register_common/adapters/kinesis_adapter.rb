require 'aws-sdk-kinesis'
require 'json'
require 'digest'
require 'securerandom'

module RegisterCommon
  module Adapters
    class KinesisAdapter
      PutRecordsError = Class.new(StandardError)

      def initialize(region:, access_key_id:, secret_access_key:)
        @client = Aws::Kinesis::Client.new(
          region: region,
          access_key_id: access_key_id,
          secret_access_key: secret_access_key,
        )
      end

      def put_records(stream_name:, records:)
        return if records.empty?

        # Set default to be a random partition
        default_partition_key = SecureRandom.hex

        mapped_records = records.map do |record|
          {
            data:          record, #.to_json, # TODO: should this be mapped to JSON here?
            partition_key: default_partition_key
          }
        end

        resp = client.put_records({
          records:     mapped_records,
          stream_name: stream_name
        })

        if resp.failed_record_count > 0
          raise PutRecordsError, resp
        end
      end

      private

      attr_reader :client
    end
  end
end
