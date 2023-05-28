# frozen_string_literal: true

require 'register_common/parsers/csv_reader'
require 'stringio'

RSpec.describe RegisterCommon::Parsers::CsvReader do
  subject { described_class.new }

  let(:iostream) { StringIO.new("example,file\na,1\nb,7") }

  describe '#foreach' do
    it 'parses with header correctly' do
      results = []
      subject.foreach(iostream) { |row| results << row }
      expect(results).to eq [{ 'example' => 'a', 'file' => '1' }, { 'example' => 'b', 'file' => '7' }]
    end
  end
end
