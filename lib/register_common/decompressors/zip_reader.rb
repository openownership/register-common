require 'zip'

module RegisterCommon
  module Decompressors
    class ZipReader
      InvalidZipError = Class.new(StandardError)

      def open_stream(stream)
        zip = Zip::File.open_buffer(stream)
        raise InvalidZipError if zip.count > 1

        yield zip.first.get_input_stream
      ensure
        zip.close
      end
    end
  end
end
