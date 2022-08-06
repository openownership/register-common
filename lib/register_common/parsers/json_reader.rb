require 'json'

module RegisterCommon
  module Parsers
    class JsonReader
      def foreach(stream, headers: true)
        stream.each { |line| yield JSON.parse(line) }
      end
    end
  end
end
