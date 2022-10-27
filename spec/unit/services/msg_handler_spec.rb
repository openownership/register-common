require 'register_common/services/msg_handler'
require 'json'
require 'stringio'

RSpec.describe RegisterCommon::Services::MsgHandler do
  subject { described_class.new(s3_adapter: s3_adapter, s3_bucket: s3_bucket) }

  let(:s3_adapter) { double 's3_adapter' }
  let(:s3_bucket) { double 's3_bucket' }

  describe '#process' do
    context 'when message is invalid json' do
      let(:data) { 'abcd' }

      it 'returns raw data' do
        result = subject.process(data)
        expect(result).to eq data
      end
    end

    context 'when message is valid json with s3_path key' do
      let(:data) { { 's3_path' => 'some_s3_path' }.to_json }
      let(:large_data) { { 'some' => 'large_data' }.to_json }

      it 'returns raw data' do
        expect(s3_adapter).to receive(:download_and_read).with(
          s3_bucket: s3_bucket,
          s3_path: 'some_s3_path'
        ).and_return large_data

        result = subject.process(data)
        expect(result).to eq large_data
      end
    end

    context 'when message is valid json without s3_path key' do
      let(:data) { { 'some' => 'data' }.to_json }

      it 'returns raw data' do
        result = subject.process(data)
        expect(result).to eq data
      end
    end
  end
end
