# frozen_string_literal: true

require 'aws-sdk-athena'

module RegisterCommon
  module Adapters
    class AthenaAdapter
      QueryTimeoutError = Class.new(StandardError)

      def initialize(credentials:)
        @client = Aws::Athena::Client.new(
          region: credentials.AWS_REGION,
          access_key_id: credentials.AWS_ACCESS_KEY_ID,
          secret_access_key: credentials.AWS_SECRET_ACCESS_KEY
        )
      end

      def get_query_execution(execution_id)
        client.get_query_execution(
          {
            query_execution_id: execution_id
          }
        )
      end

      def start_query_execution(params)
        client.start_query_execution(params)
      end

      def wait_for_query(execution_id, max_time: 300, wait_interval: 5)
        max_time.times do
          query = get_query_execution(execution_id)
          return query if query.query_execution.status.state == 'SUCCEEDED'

          sleep wait_interval
        end

        raise QueryTimeoutError
      end

      def execute_and_wait(sql_query, output_location)
        athena_query = start_query_execution(
          {
            query_string: sql_query,
            result_configuration: {
              output_location:
            }
          }
        )
        wait_for_query(athena_query.query_execution_id)
      end

      private

      attr_reader :client
    end
  end
end
