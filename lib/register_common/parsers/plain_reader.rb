# frozen_string_literal: true

module RegisterCommon
  module Parsers
    class PlainReader
      def foreach(stream, &)
        stream.each(&)
      end
    end
  end
end
