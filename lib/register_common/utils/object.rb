# frozen_string_literal: true

module RegisterCommon
  module Utils
    module Object
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def self.compact_deep(obj, prune: false)
        obj2 = if obj.respond_to?(:transform_values)
                 obj.transform_values { |v| compact_deep(v, prune:) }.compact
               elsif obj.respond_to?(:map)
                 obj.map { |e| compact_deep(e, prune:) }.compact
               else
                 obj
               end
        obj2 = nil if prune && obj.respond_to?(:empty?) && obj.empty?
        obj2
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
end
