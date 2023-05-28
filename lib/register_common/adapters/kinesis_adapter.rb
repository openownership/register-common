# frozen_string_literal: true

require 'aws-sdk-kinesis'
require 'json'
require 'digest'
require 'securerandom'

module RegisterCommon
  module Adapters
    class KinesisAdapter
      PutRecordsError = Class.new(StandardError)

      def initialize(credentials:)
        @client = Aws::Kinesis::Client.new(
          region: credentials.AWS_REGION,
          access_key_id: credentials.AWS_ACCESS_KEY_ID,
          secret_access_key: credentials.AWS_SECRET_ACCESS_KEY
        )
      end

      def put_records(stream_name:, records:)
        return if records.empty?

        # Set default to be a random partition
        default_partition_key = SecureRandom.hex

        mapped_records = records.map do |record|
          {
            data: record, # .to_json, # TODO: should this be mapped to JSON here?
            partition_key: default_partition_key
          }
        end

        resp = client.put_records({
                                    records: mapped_records,
                                    stream_name:
                                  })

        return unless resp.failed_record_count.positive?

        raise PutRecordsError, resp
      end

      private

      attr_reader :client
    end
  end
end
