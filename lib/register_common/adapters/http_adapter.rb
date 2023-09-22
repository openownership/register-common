# frozen_string_literal: true

require 'uri'
require 'faraday'
require 'faraday_middleware'
# Add persistent http option

module RegisterCommon
  module Adapters
    class HttpAdapter
      HttpError = Class.new(StandardError)
      HttpResponse = Struct.new(:status, :headers, :body, :success)

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def get(url, params: {}, headers: {}, raise_on_failure: false)
        streamed = nil
        response =
          if block_given?
            streamed = []
            current_chunk = ''

            Faraday.new.get(
              URI(url), params, headers
            ) do |req|
              req.options.on_data = proc do |chunk, _overall_received_bytes|
                current_chunk += chunk
                lines = current_chunk.split("\n")
                if current_chunk[-1] == "\n"
                  lines[0...-1].each do |line|
                    next if line.empty?

                    yield line
                  end
                  current_chunk = ''
                elsif lines.length > 1
                  lines[0...-1].each do |line|
                    next if line.empty?

                    yield line
                  end
                  current_chunk = lines[-1]
                end
                streamed << chunk
              end
            end
          else
            Faraday.new.get(
              URI(url), params, headers
            )
          end

        raise HttpError if !response.success? && raise_on_failure

        HttpResponse.new(response.status, response.headers, streamed ? streamed.join : response.body, response.success?)
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
end
