require 'register_common/decompressors/gzip_reader'

RSpec.describe RegisterCommon::Decompressors::GzipReader do
  subject { described_class.new }

  describe '#open_stream' do
    context 'when given a valid gzipped stream' do
      it 'unzips successfully' do
        result = File.open('./spec/fixtures/sample_file.gz') do |stream|
          subject.open_stream(stream) { |unzipped| unzipped.read }
        end

        expect(result).to eq "HELLO WORLD\nTESTING GZIP\n\n"
      end
    end
  end
end
