# frozen_string_literal: true

require 'redis'

module RegisterCommon
  module Utils
    class ExpiringSet
      def initialize(redis: nil, namespace: nil, ttl: 60)
        @redis = redis
        @namespace = namespace
        @ttl = ttl
      end

      def sadd(key, member)
        t = Time.now.utc.to_i / @ttl
        idx = _k_idx(key)
        key1 = [idx, t].join('/')
        @redis.sadd(idx, key1)
        @redis.sadd(key1, member)
        @redis.expire(key1, @ttl * 2, nx: true)
      end

      def sismember(key, member)
        idx = _k_idx(key)
        @redis.smembers(idx).each do |key1|
          @redis.srem(idx, key1) unless @redis.exists?(key1)
          return true if @redis.sismember(key1, member)
        end
        false
      end

      private

      def _k_idx(key)
        [@namespace, key].join('/')
      end
    end
  end
end
