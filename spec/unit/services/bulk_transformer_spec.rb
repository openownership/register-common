# frozen_string_literal: true

require 'register_common/adapters/s3_adapter'
require 'register_common/services/bulk_transformer'
require 'register_common/services/set_client_redis'

RSpec.describe RegisterCommon::Services::BulkTransformer do
  subject(:bulk_transformer) do
    described_class.new(
      s3_adapter:,
      s3_bucket:,
      set_client:,
      file_reader: nil,
      batch_size: nil,
    )
  end

  let(:s3_adapter) { instance_double RegisterCommon::Adapters::S3Adapter }
  let(:set_client) { instance_double RegisterCommon::Services::SetClientRedis }
  let(:file_reader) { instance_double RegisterCommon::Services::FileReader }
  let(:s3_bucket) { 's3_bucket' }

  describe '#call' do
    let(:raw_rows) do
      [
        '{ "a": "x" }',
        '{ "s3_path": "example_path" }',
      ]
    end

    it 'yields rows' do
      large_data = '{ "large": "data" }'
      s3_prefix = 'some-prefix'
      s3_path = 'some-prefix/some-path'
      set_key = 'BULK_TRANSFORMER:some-prefix'

      processed_files = instance_double RegisterCommon::Services::SetClientRedis::MySet

      allow(RegisterCommon::Services::FileReader).to receive(:new).with(s3_adapter:, batch_size: 25).and_return file_reader
      allow(file_reader).to receive(:read_from_s3).with(s3_bucket:, s3_path:).and_yield(raw_rows)
      allow(set_client).to receive(:init_set).with(set_key).and_return processed_files
      allow(s3_adapter).to receive(:list_objects).with(s3_bucket:, s3_prefix:).and_return [s3_path]
      allow(s3_adapter).to receive(:download_and_read).with(s3_bucket:, s3_path: 'example_path').and_return large_data
      allow(processed_files).to receive(:contains?).with(s3_path).and_return false
      allow(processed_files).to receive(:add).with(s3_path)

      row_batches = []

      bulk_transformer.call(s3_prefix) do |rows|
        row_batches << rows
      end

      expect(row_batches).to eq [
        ['{ "a": "x" }', large_data],
      ]
    end
  end
end
