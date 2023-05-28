# frozen_string_literal: true

require 'register_common/services/stream_client_kinesis'

RSpec.describe RegisterCommon::Services::StreamClientKinesis do
  subject do
    described_class.new(credentials:, stream_name:, redis:, client:)
  end

  let(:redis) { double 'redis' }
  let(:client) { double 'client' }
  let(:stream_name) { 'stream_name' }
  let(:credentials) do
    double 'credentials', AWS_REGION: 'AWS_REGION',
                          AWS_ACCESS_KEY_ID: 'AWS_ACCESS_KEY_ID',
                          AWS_SECRET_ACCESS_KEY: 'AWS_SECRET_ACCESS_KEY'
  end

  describe '#consume' do
    let(:consumer_id) { 'consumer_id' }

    context 'when no offset is stored' do
      it 'consumes from beginning of stream' do
        shard_ids = ['shard1']
        shard_iterator = 'iterator1'
        next_shard_iterator = 'next-iterator1'
        shards = double 'shards', shards: shard_ids.map { |shard_id| double('shard_id', shard_id:) }
        records = [double('record', data: 'data1', sequence_number: 'seq1')]

        expect(redis).to receive(:get).with('kinesis_consumer_id_shard1').and_return nil
        allow(redis).to receive(:set)

        expect(client).to receive(:list_shards).with(
          { stream_name: },
        ).and_return shards

        expect(client).to receive(:get_shard_iterator).with(
          {
            shard_id: 'shard1',
            shard_iterator_type: 'TRIM_HORIZON',
            starting_sequence_number: nil,
            stream_name:,
          },
        ).and_return double('shard_iterator', shard_iterator:)

        expect(client).to receive(:get_records).with(
          { limit: 50, shard_iterator: 'iterator1' },
        ).and_return(
          double('resp', records:, next_shard_iterator:),
        )

        records = []
        subject.consume(consumer_id, limit: 1) { |record| records << record }

        expect(records).to eq ['data1']
        expect(redis).to have_received(:set).with(
          'kinesis_consumer_id_shard1', 'seq1', ex: 60 * 60 * 24
        )
      end
    end

    context 'when offset is stored' do
      it 'consumes from beginning of stream' do
        shard_ids = ['shard1']
        shard_iterator = 'iterator1'
        next_shard_iterator = 'next-iterator1'
        shards = double 'shards', shards: shard_ids.map { |shard_id| double('shard_id', shard_id:) }
        records = [double('record', data: 'data1', sequence_number: 'seq1')]

        expect(redis).to receive(:get).with('kinesis_consumer_id_shard1').and_return 'stored-seq'
        allow(redis).to receive(:set)

        expect(client).to receive(:list_shards).with(
          { stream_name: },
        ).and_return shards

        expect(client).to receive(:get_shard_iterator).with(
          {
            shard_id: 'shard1',
            shard_iterator_type: 'AFTER_SEQUENCE_NUMBER',
            starting_sequence_number: 'stored-seq',
            stream_name:,
          },
        ).and_return double('shard_iterator', shard_iterator:)

        expect(client).to receive(:get_records).with(
          { limit: 50, shard_iterator: 'iterator1' },
        ).and_return(
          double('resp', records:, next_shard_iterator:),
        )

        records = []
        subject.consume(consumer_id, limit: 1) { |record| records << record }

        expect(records).to eq ['data1']
        expect(redis).to have_received(:set).with(
          'kinesis_consumer_id_shard1', 'seq1', ex: 60 * 60 * 24
        )
      end
    end
  end
end
