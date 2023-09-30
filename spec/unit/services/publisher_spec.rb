# frozen_string_literal: true

require 'register_common/services/publisher'
require 'json'
require 'stringio'

RSpec.describe RegisterCommon::Services::Publisher do
  subject do
    described_class.new(
      stream_name:,
      kinesis_adapter:,
      buffer_size:,
      s3_adapter:,
      s3_bucket:,
      s3_prefix:,
      serializer:
    )
  end

  let(:stream_name) { double 'stream_name' }
  let(:kinesis_adapter) { double 'kinesis_adapter' }
  let(:buffer_size) { 10 }
  let(:s3_adapter) { double 's3_adapter' }
  let(:s3_bucket) { 's3_bucket' }
  let(:s3_prefix) { '/some/s3/prefix' }
  let(:serializer) { double 'serializer' }

  describe '#publish' do
    context 'when msg is string' do
      let(:msg) { 'msg' }

      # rubocop:disable RSpec/NoExpectationExample
      it 'publishes msg' do
        subject.publish msg
      end
      # rubocop:enable RSpec/NoExpectationExample
    end

    context 'when msg is not a string' do
      let(:msg) { double 'msg' }

      it 'serializes the msg' do
        serialized = 'serialized'

        expect(serializer).to receive(:serialize).with(msg).and_return serialized

        subject.publish msg
      end
    end

    context 'when msg is large' do
      let(:msg) { (1..1_000_000).map(&:to_s).join(',') }

      it 'stores msg on S3' do
        allow(s3_adapter).to receive(:upload_from_file_obj_to_s3)
        allow(kinesis_adapter).to receive(:put_records)
        expect(s3_adapter).to receive(:exists?).with(
          s3_bucket:,
          s3_path: '/some/s3/prefix/2439106918277298582'
        ).and_return false

        subject.publish msg

        expect(s3_adapter).to have_received(:upload_from_file_obj_to_s3)
        expect(kinesis_adapter).to have_received(:put_records).with(
          {
            records: ["{\"s3_path\":\"/some/s3/prefix/2439106918277298582\"}\n"],
            stream_name:
          }
        )
      end
    end
  end

  describe '#finalize' do
    context 'when buffer is empty' do
      it 'will not publish a message' do
        expect(kinesis_adapter).not_to receive(:put_records)

        subject.finalize
      end
    end

    context 'when buffer is not empty' do
      before do
        subject.publish 'msg'
      end

      it 'publishes messages from buffer' do
        allow(kinesis_adapter).to receive(:put_records)

        subject.finalize

        expect(kinesis_adapter).to have_received(:put_records).with(
          records: ["msg\n"],
          stream_name:
        )
      end
    end
  end
end
