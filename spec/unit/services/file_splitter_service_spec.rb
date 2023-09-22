# frozen_string_literal: true

require 'register_common/services/file_splitter_service'
require 'register_common/decompressors/gzip_reader'
require 'stringio'

RSpec.describe RegisterCommon::Services::FileSplitterService do
  subject { described_class.new }

  let(:gzip_reader) { RegisterCommon::Decompressors::GzipReader.new }

  describe '#split_stream' do
    let(:content) { (1..1000).map { |i| "LINE#{i}" }.join("\n") + "\n" } # rubocop:disable Style/StringConcatenation

    it 'splits correctly' do
      stream = StringIO.new(content)

      file_count = 0
      subject.split_stream(stream, split_size: 100) do |file_path|
        result = File.open(file_path) do |stream2|
          gzip_reader.open_stream(stream2, &:read)
        end

        starting_line = (file_count * 100) + 1
        expect(result).to eq (starting_line...(starting_line + 100)).map { |i| "LINE#{i}" }.join("\n") + "\n" # rubocop:disable Style/StringConcatenation

        file_count += 1
      end

      expect(file_count).to eq 10
    end
  end
end
