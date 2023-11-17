# frozen_string_literal: true

module RegisterCommon
  module Elasticsearch
    module Query
      def self.search_scroll(client, query, &)
        response = client.search(**query, scroll: '10m')
        scroll_id = response['_scroll_id']
        response['hits']['hits'].each(&)
        while response['hits']['hits'].size.positive?
          response = client.scroll(body: { scroll_id: }, scroll: '5m')
          response['hits']['hits'].each(&)
        end
      end
    end
  end
end
