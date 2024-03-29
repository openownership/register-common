# frozen_string_literal: true

require 'stringio'
require 'zip'
require 'register_common/decompressors/zip_reader'

RSpec.describe RegisterCommon::Decompressors::ZipReader do
  subject { described_class.new }

  describe '#open_stream' do
    context 'when opening a valid zip file' do
      let(:zipfile_name) { '/tmp/zipfile.zip' } # TODO: mkdir tmpdir
      let(:content) { 'sample content' }
      let(:zipstream) do
        c = File.read(zipfile_name)
        StringIO.open(c)
      end

      before do
        Zip::File.open(zipfile_name, create: true) do |zipfile|
          zipfile.get_output_stream('myFile') { |f| f.write content }
        end
      end

      it 'returns stream with correct data' do
        result = subject.open_stream(zipstream, &:read)
        expect(result).to eq content
      end
    end

    context 'when opening an existing zip file' do
      it 'reads file correctly' do
        File.open('spec/fixtures/example.zip') do |f|
          content = subject.open_stream(f, &:read)
          expect(content).to eq "{ \"hello\": \"world\" }\r\n{ \"hello2\": \"world2\" }\r\n"
        end
      end
    end
  end
end
