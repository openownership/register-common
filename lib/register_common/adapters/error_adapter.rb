module RegisterCommon
  module Adapters
    class ErrorAdapter
      def error(message)
        nil # TODO: Rollbar
      end
    end
  end
end
