# frozen_string_literal: true

module RegisterCommon
  module Parsers
    module FileFormats
      PLAIN = 'plain'
      CSV = 'csv'
      JSON = 'json'
    end

    UnknownFileFormatError = Class.new(StandardError)
  end
end
