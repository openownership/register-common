# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'uri'

module RegisterCommon
  module Adapters
    class HttpAdapter
      HttpError = Class.new(StandardError)

      HttpResponse = Struct.new(:status, :headers, :body, :success)

      def get(url, params: {}, headers: {}, raise_on_failure: false, &block)
        url = URI(url)
        res = if block_given?
                get_streamed(url, params, headers, &block)
              else
                get_all(url, params, headers)
              end
        raise HttpError if !res.success? && raise_on_failure

        HttpResponse.new(res.status, res.headers, res.body, res.success?)
      end

      private

      def get_all(url, params, headers)
        Faraday.new.get(url, params, headers)
      end

      def get_streamed(url, params, headers)
        bfr = ''
        Faraday.new.get(url, params, headers) do |req|
          req.options.on_data = proc do |chunk|
            bfr += chunk
            lines = bfr.split("\n", -1)
            lines[0...-1].each do |line|
              yield line unless line.empty?
            end
            bfr = lines[-1]
          end
        end
      end
    end
  end
end
