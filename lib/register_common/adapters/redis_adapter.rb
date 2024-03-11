# frozen_string_literal: true

require 'redis'

module RegisterCommon
  module Adapters
    class RedisAdapter
      def initialize(url:)
        @redis = Redis.new(url:)
      end

      def sismember(key, element)
        redis.sismember(key, element)
      end

      def sadd(key, element)
        redis.sadd(key, [element])
      end

      def srem(key, element)
        redis.srem(key, [element])
      end

      private

      attr_reader :redis
    end
  end
end
