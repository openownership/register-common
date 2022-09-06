module RegisterCommon
  module Utils
    module Mixins
      module RetryWithBackoff
        DEFAULT_RETRIES = 10

        def retry_with_backoff(max_retries=DEFAULT_RETRIES)
          retry_count = 0
          result = nil

          while true
            begin
              result = yield
              break
            rescue => e
              # LOGGER.warn e.message
              if retry_count < max_retries
                sleep retry_count
                retry_count += 1
              else
                raise
              end
            end
          end

          result
        end
      end
    end
  end
end
