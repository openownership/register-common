module RegisterCommon
  module Services
    class SetClientRedis
      class MySet
        def initialize(redis_adapter:, key:)
          @redis_adapter = redis_adapter
          @key = key
        end

        attr_reader :key

        def add(element)
          redis_adapter.sadd(key, element)
        end

        def remove(element)
          redis_adapter.srem(key, element)
        end

        def contains?(element)
          redis_adapter.sismember(key, element)
        end

        private

        attr_reader :redis_adapter
      end

      def initialize(redis_adapter:)
        @redis_adapter = redis_adapter
      end

      def init_set(key)
        MySet.new(redis_adapter:, key:)
      end

      private

      attr_reader :redis_adapter
    end
  end
end
