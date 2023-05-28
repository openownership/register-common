# frozen_string_literal: true

module RegisterCommon
  module Utils
    module Mixins
      module RetryWithBackoff
        DEFAULT_RETRIES = 10

        def retry_with_backoff(max_retries = DEFAULT_RETRIES)
          retry_count = 0
          result = nil

          loop do
            result = yield
            break
          rescue StandardError
            # LOGGER.warn e.message
            raise unless retry_count < max_retries

            sleep retry_count
            retry_count += 1
          end

          result
        end
      end
    end
  end
end
