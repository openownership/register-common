# frozen_string_literal: true

module RegisterCommon
  module Elasticsearch
    module Query
      SCROLL_TIME = '10m'

      def self.search_scroll(client, query, &)
        response = client.search(**query, scroll: SCROLL_TIME)
        scroll_id = response['_scroll_id']
        response['hits']['hits'].each(&)
        while response['hits']['hits'].size.positive?
          response = client.scroll(body: { scroll_id: }, scroll: SCROLL_TIME)
          scroll_id = response['_scroll_id']
          response['hits']['hits'].each(&)
        end
      end
    end
  end
end
