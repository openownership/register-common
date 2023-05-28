# frozen_string_literal: true

require 'register_common/parsers/parser'

RSpec.describe RegisterCommon::Parsers::Parser do
  subject do
    described_class.new(
      csv_reader:,
      json_reader:,
      plain_reader:,
    )
  end

  let(:csv_reader) { double 'csv_reader' }
  let(:json_reader) { double 'json_reader' }
  let(:plain_reader) { double 'plain_reader' }

  let(:stream) { double 'stream' }
  let(:row) { double 'row' }
  let(:func) { double 'func' }

  before { allow(func).to receive(:call) }

  describe '#foreach' do
    context 'when file_format is "csv"' do
      let(:file_format) { RegisterCommon::Parsers::FileFormats::CSV }

      it 'yields parsed CSV rows' do
        expect(csv_reader).to receive(:foreach).with(stream).and_yield row

        subject.foreach(stream, file_format:) { |s| func.call s }
        expect(func).to have_received(:call).with(row)
      end
    end

    context 'when file_format is "json"' do
      let(:file_format) { RegisterCommon::Parsers::FileFormats::JSON }

      it 'yields parsed JSON rows' do
        expect(json_reader).to receive(:foreach).with(stream).and_yield row

        subject.foreach(stream, file_format:) { |s| func.call s }
        expect(func).to have_received(:call).with(row)
      end
    end

    context 'when file_format is "plain"' do
      let(:file_format) { RegisterCommon::Parsers::FileFormats::PLAIN }

      it 'yields each line unmodified' do
        expect(plain_reader).to receive(:foreach).with(stream).and_yield row

        subject.foreach(stream, file_format:) { |s| func.call s }
        expect(func).to have_received(:call).with(row)
      end
    end

    context 'when file_format is invalid' do
      let(:file_format) { 'invalid' }

      it 'raises UnknownFileFormatError' do
        expect do
          subject.foreach(stream, file_format:) { |s| func.call s }
        end.to raise_error RegisterCommon::Parsers::UnknownFileFormatError

        expect(func).not_to have_received(:call)
      end
    end
  end
end
