require 'register_common/decompressors/decompressor'

RSpec.describe RegisterCommon::Decompressors::Decompressor do
  subject do
    described_class.new(
      gzip_reader: gzip_reader,
      zip_reader: zip_reader
    )
  end

  let(:gzip_reader) { double 'gzip_reader' }
  let(:zip_reader) { double 'zip_reader' }

  let(:stream) { double 'stream' }

  describe '#with_deflated_stream' do
    let(:func) { double 'func' }
    let(:deflated_stream) { double 'deflated_stream' }

    before do
      allow(func).to receive(:call)
    end

    context 'when compression_type is "none"' do
      let(:compression) { RegisterCommon::Decompressors::CompressionTypes::NONE }
      let(:deflated_stream) { stream }

      it 'yields unmodified stream' do
        subject.with_deflated_stream(stream, compression: compression) { |s| func.call s }
        expect(func).to have_received(:call).with(deflated_stream)
      end
    end

    context 'when compression_type is "zip"' do
      let(:compression) { RegisterCommon::Decompressors::CompressionTypes::ZIP }

      it 'yields decompressed zip stream' do
        expect(zip_reader).to receive(:open_stream).with(stream).and_yield(deflated_stream)

        subject.with_deflated_stream(stream, compression: compression) { |s| func.call s }
        expect(func).to have_received(:call).with(deflated_stream)
      end
    end

    context 'when compression_type is "gzip"' do
      let(:compression) { RegisterCommon::Decompressors::CompressionTypes::GZIP }

      it 'yields decompressed gzip stream' do
        expect(gzip_reader).to receive(:open_stream).with(stream).and_yield(deflated_stream)

        subject.with_deflated_stream(stream, compression: compression) { |s| func.call s }
        expect(func).to have_received(:call).with(deflated_stream)
      end
    end

    context 'when compression_type is invalid' do
      let(:compression) { 'invalid' }

      it 'raises UnknownCompressionTypeError' do
        expect do
          subject.with_deflated_stream(stream, compression: compression) { |s| func.call s }
        end.to raise_error RegisterCommon::Decompressors::UnknownCompressionTypeError

        expect(func).not_to have_received(:call)
      end
    end
  end
end
