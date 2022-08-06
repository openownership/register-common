require 'json'

module RegisterCommon
  module Utils
    class JsonReader
      def foreach(stream, headers: true, &block)
        stream.each { |line| yield JSON.parse(line) }
      end
    end
  end
end
