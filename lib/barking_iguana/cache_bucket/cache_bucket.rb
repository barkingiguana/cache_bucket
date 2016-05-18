require 'null_logger'

module BarkingIguana
  module CacheBucket
    class CacheBucket
      KEY_DIVIDER = '__'.freeze

      attr_accessor :maximum_age
      private :maximum_age=, :maximum_age

      attr_accessor :logger
      private :logger=, :logger

      attr_accessor :last_cleaned
      private :last_cleaned=, :last_cleaned

      attr_accessor :cache
      private :cache=, :cache

      def initialize maximum_age: 3600, logger: nil
        self.maximum_age = maximum_age.to_i
        self.logger = logger || NullLogger.instance
        self.cache = {}
      end

      def get key
        logger.debug { "Getting #{key}" }
        evict_expired_keys
        k = generation_key(key)
        if cache.key? k
          logger.debug { "Key #{k.inspect} found in the cache" }
          cache[k].tap do |v|
            logger.debug { "Value is #{v.inspect}" }
          end
        else
          logger.debug { "Key #{k.inspect} is not in the cache" }
          return unless block_given?
          logger.debug { "I was passed a block to calculate the value" }
          yield.tap do |v|
            logger.debug { "Calculated value: #{v.inspect}" }
            set key, v
          end
        end
      end

      def set key, value
        evict_expired_keys
        k = generation_key(key)
        logger.debug { "Setting value to #{value.inspect}" }
        cache[k] = value
      end

      private

      def evict_expired_keys
        g = generation_id
        return if g == last_cleaned
        logger.debug { "Performing cache maintenance at generation #{g}" }
        count = cache.keys.size
        cache.delete_if do |k, _v|
          k !~ %r{^#{g}#{KEY_DIVIDER}}
        end
        logger.debug { "Deleted #{count - cache.keys.size} keys" }
        self.last_cleaned = g
      end

      def generation_id
        Time.now.to_i / maximum_age
      end

      def generation_key key
        [ generation_id, key ].join(KEY_DIVIDER).tap do |k|
          logger.debug { "Current generation key for #{key.inspect} is #{k.inspect}" }
        end
      end
    end
  end
end
