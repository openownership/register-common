# frozen_string_literal: true

module RegisterCommon
  module Decompressors
    UnknownCompressionTypeError = Class.new(StandardError)

    module CompressionTypes
      NONE = 'none'
      GZIP = 'gzip'
      ZIP  = 'zip'
    end
  end
end
