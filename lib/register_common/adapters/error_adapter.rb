# frozen_string_literal: true

module RegisterCommon
  module Adapters
    class ErrorAdapter
      def error(_message)
        nil # TODO: Rollbar
      end
    end
  end
end
