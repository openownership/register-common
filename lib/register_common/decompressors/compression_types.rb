module RegisterCommon
  module Decompressors
    module CompressionTypes
      NONE = 'none'
      GZIP = 'gzip'
      ZIP = 'zip'
    end

    UnknownCompressionTypeError = Class.new(StandardError)
  end
end
