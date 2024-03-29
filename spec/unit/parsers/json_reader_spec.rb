# frozen_string_literal: true

require 'register_common/parsers/json_reader'
require 'stringio'

RSpec.describe RegisterCommon::Parsers::JsonReader do
  subject { described_class.new }

  let(:iostream) do
    StringIO.new(<<~JSON
      {"hello": "world"}
      {"more": "content"}
    JSON
                )
  end

  describe '#foreach' do
    context 'when JSON is valid' do
      it 'parses with header correctly' do
        results = []
        subject.foreach(iostream) { |row| results << row }
        expect(results).to eq [{ 'hello' => 'world' }, { 'more' => 'content' }]
      end
    end

    context 'when JSON has errors' do
      let(:iostream) { StringIO.new('{"hello: "world"}') }

      it 'raises an error' do
        expect do
          results = []
          subject.foreach(iostream) { |row| results << row }
        end.to raise_error JSON::ParserError
      end
    end
  end
end
