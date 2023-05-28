# frozen_string_literal: true

module RegisterCommon
  module Parsers
    class PlainReader
      def foreach(stream, &block)
        stream.each(&block)
      end
    end
  end
end
