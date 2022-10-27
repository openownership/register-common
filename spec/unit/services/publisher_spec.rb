require 'register_common/services/publisher'
require 'json'
require 'stringio'

RSpec.describe RegisterCommon::Services::Publisher do
  subject do
    described_class.new(
      stream_name: stream_name,
      kinesis_adapter: kinesis_adapter,
      buffer_size: buffer_size,
      s3_adapter: s3_adapter,
      s3_prefix: s3_prefix,
      serializer: serializer
    )
  end

  let(:stream_name) { double 'stream_name' }
  let(:kinesis_adapter) { double 'kinesis_adapter' }
  let(:buffer_size) { double 'buffer_size' }
  let(:s3_adapter) { double 's3_adapter' }
  let(:s3_prefix) { double 's3_prefix' }
  let(:serializer) { double 'serializer' }

  describe '#publish' do

  end

  describe '#finalize' do

  end
end
