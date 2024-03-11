# frozen_string_literal: true

module RegisterCommon
  module Utils
    class PaginatedArray < Array
      # rubocop:disable Metrics/ParameterLists
      def initialize(source_array, current_page: 0, records_per_page: 10, limit_value: nil, total_count: nil, aggs: nil)
        @source_array = source_array

        @current_page = current_page
        @records_per_page = records_per_page
        @limit_value = limit_value
        @total_count = total_count || source_array.count
        @aggs = aggs

        super(source_array)
      end
      # rubocop:enable Metrics/ParameterLists

      attr_reader :current_page, :records_per_page, :limit_value, :total_count, :aggs

      def limit(lim)
        new_limit = [limit_value, lim].compact.min
        PaginatedArray.new(
          source_array[0...new_limit],
          current_page:,
          records_per_page:,
          limit_value: new_limit,
          total_count:
        )
      end

      def page(page_num)
        PaginatedArray.new(
          source_array[0...n],
          current_page: page_num,
          records_per_page:,
          limit_value:,
          total_count:
        )
      end

      def per(max_per_page)
        PaginatedArray.new(
          source_array[0...n],
          current_page:,
          records_per_page: max_per_page,
          limit_value:,
          total_count:
        )
      end

      def total_pages
        (total_count * 1.0 / records_per_page).ceil
      end

      def order_by(**_args)
        self
      end

      def offset_value
        (current_page - 1) * records_per_page
      end

      private

      attr_reader :source_array
    end
  end
end
