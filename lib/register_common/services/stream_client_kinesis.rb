require 'aws-sdk-kinesis'
require 'redis'

module RegisterCommon
  module Services
    class StreamClientKinesis
      EXPIRY_SECS = 60 * 60 * 24 # 1 day

      def initialize(credentials:, redis: nil, stream_name: nil)
        @redis = redis || Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'])
        @client = Aws::Kinesis::Client.new(
          region: credentials.AWS_REGION,
          access_key_id: credentials.AWS_ACCESS_KEY_ID,
          secret_access_key: credentials.AWS_SECRET_ACCESS_KEY
        )
        @stream_name = stream_name || 'psc-test-stream'
      end

      def consume
        print "LISTING SHARDS\n"
        shard_ids = list_shards

        print "LISTING SEQUENCE NUMBERSFOR SHARDS #{shard_ids}\n"
        sequence_numbers = shard_ids.map { |shard_id| [shard_id, get_sequence_number(shard_id)] }.to_h

        print "LISTING ITERATORS FOR SEQUENCE NUMBERS #{sequence_numbers}\n"
        iterators = sequence_numbers.map do |shard_id, seq_number|
          [shard_id, get_shard_iterator(shard_id, sequence_number: seq_number)]
        end.to_h

        print "STARTING WITH ITERATORS: #{iterators}\n"
        while true
          shard_ids = iterators.keys
          shard_ids.each do |shard_id|
            iterator = iterators[shard_id]
            resp = client.get_records({ shard_iterator: iterator, limit: 50 })
            next if resp.records.empty?

            resp.records.each do |record|
              yield record.data
            end

            iterators[shard_id] = resp.next_shard_iterator
            
            store_sequence_number(shard_id, resp.records[-1].sequence_number)
          end

          print("SLEEPING\n")
          sleep 1
        end
      end

      private

      attr_reader :redis, :client, :stream_name

      def list_shards
        client.list_shards({ stream_name: stream_name }).shards.map(&:shard_id)
      end

      def get_sequence_number(shard_id)
        print("GET SEQ NUMBER: ", shard_id, "\n")
        redis.get shard_id
      end

      def get_shard_iterator(shard_id, sequence_number: nil)
        shard_iterator_type = sequence_number ? "AFTER_SEQUENCE_NUMBER" : "TRIM_HORIZON"

        client.get_shard_iterator({
          stream_name: stream_name,
          shard_id: shard_id,
          shard_iterator_type: shard_iterator_type,
          starting_sequence_number: sequence_number
        }).shard_iterator
      end

      def get_records(shard_iterator)
        client.get_records({ shard_iterator: shard_iterator, limit: 50 })
      end

      def store_sequence_number(shard_id, sequence_number)
        if sequence_number
          redis.set(shard_id, sequence_number, ex: EXPIRY_SECS)
        else
          redis.del(shard_id)
        end
      end
    end
  end
end
