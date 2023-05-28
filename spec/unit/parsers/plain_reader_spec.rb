# frozen_string_literal: true

require 'register_common/parsers/plain_reader'
require 'stringio'

RSpec.describe RegisterCommon::Parsers::PlainReader do
  subject { described_class.new }

  let(:iostream) { StringIO.new("example,file\na,1\nb,7") }

  describe '#foreach' do
    it 'parses with header correctly' do
      results = []
      subject.foreach(iostream) { |row| results << row }
      expect(results).to eq ["example,file\n", "a,1\n", 'b,7']
    end
  end
end
