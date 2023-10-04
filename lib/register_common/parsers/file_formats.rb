# frozen_string_literal: true

module RegisterCommon
  module Parsers
    UnknownFileFormatError = Class.new(StandardError)

    module FileFormats
      PLAIN = 'plain'
      CSV   = 'csv'
      JSON  = 'json'
    end
  end
end
