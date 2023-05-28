# frozen_string_literal: true

require 'register_common/services/file_reader'
require 'stringio'

RSpec.describe RegisterCommon::Services::FileReader do
  subject { described_class.new }

  let(:s3_adapter) { double 's3_adapter' }
  let(:decompressor) { double 'decompressor' }
  let(:parser) { double 'parser' }

  describe '#read_from_s3' do
  end

  describe '#read_from_local_path' do
  end

  describe '#read_from_stream' do
  end
end
