# frozen_string_literal: true

require 'aws-sdk-kinesis'
require 'redis'

require_relative 'msg_handler'

module RegisterCommon
  module Services
    class StreamClientKinesis
      EXPIRY_SECS = 60 * 60 * 24 # 1 day

      # rubocop:disable Metrics/ParameterLists
      def initialize(
        credentials:, stream_name:, msg_handler: nil, s3_adapter: nil, s3_bucket: nil, redis: nil,
        client: nil
      )
        @redis = redis || Redis.new(host: ENV.fetch('REDIS_HOST', nil), port: ENV.fetch('REDIS_PORT', nil))
        @msg_handler = msg_handler || MsgHandler.new(s3_adapter:, s3_bucket:)
        @client = client || Aws::Kinesis::Client.new(
          region: credentials.AWS_REGION,
          access_key_id: credentials.AWS_ACCESS_KEY_ID,
          secret_access_key: credentials.AWS_SECRET_ACCESS_KEY
        )
        @stream_name = stream_name
      end
      # rubocop:enable Metrics/ParameterLists

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def consume(consumer_id, limit: nil)
        shard_ids = list_shards

        sequence_numbers = shard_ids.to_h do |shard_id|
          sequence_number = get_sequence_number(consumer_id, shard_id)
          [shard_id, sequence_number]
        end

        iterators = sequence_numbers.to_h do |shard_id, seq_number|
          [shard_id, get_shard_iterator(shard_id, sequence_number: seq_number)]
        end

        record_count = 0
        complete = false
        until complete
          shard_ids = iterators.keys
          shard_ids.each do |shard_id|
            iterator = iterators[shard_id]
            resp = client.get_records({ shard_iterator: iterator, limit: 50 })
            iterators[shard_id] = resp.next_shard_iterator

            next if resp.records.empty?

            last_record = nil
            resp.records.each do |record|
              yield msg_handler.process(record.data)

              record_count += 1
              last_record = record

              if limit && (record_count >= limit)
                complete = true
                break
              end
            end

            iterators[shard_id] = resp.next_shard_iterator
            store_sequence_number(consumer_id, shard_id, last_record.sequence_number)

            break if complete
          end

          break if complete

          sleep 1
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      private

      attr_reader :redis, :client, :stream_name, :msg_handler

      def list_shards
        client.list_shards({ stream_name: }).shards.map(&:shard_id)
      end

      def get_shard_iterator(shard_id, sequence_number: nil)
        shard_iterator_type = sequence_number ? 'AFTER_SEQUENCE_NUMBER' : 'TRIM_HORIZON'

        client.get_shard_iterator(
          {
            stream_name:,
            shard_id:,
            shard_iterator_type:,
            starting_sequence_number: sequence_number
          }
        ).shard_iterator
      end

      def get_records(shard_iterator)
        client.get_records({ shard_iterator:, limit: 50 })
      end

      def get_sequence_number(consumer_id, shard_id)
        key = redis_key(consumer_id, shard_id)
        redis.get key
      end

      def store_sequence_number(consumer_id, shard_id, sequence_number)
        key = redis_key(consumer_id, shard_id)
        if sequence_number
          redis.set(key, sequence_number, ex: EXPIRY_SECS)
        else
          redis.del(key)
        end
      end

      def redis_key(consumer_id, shard_id)
        "kinesis_#{consumer_id}_#{shard_id}"
      end
    end
  end
end
