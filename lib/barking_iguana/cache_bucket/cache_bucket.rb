require 'null_logger'

module BarkingIguana
  module CacheBucket
    class CacheBucket
      SHARED_PREFIX = '##shared##'.freeze
      KEY_DIVIDER = '__'.freeze
      MAXIMUM_AGE = 3600

      attr_accessor :maximum_age
      private :maximum_age=, :maximum_age

      attr_accessor :logger
      private :logger=, :logger

      attr_accessor :last_cleaned
      private :last_cleaned=, :last_cleaned

      attr_accessor :cache
      private :cache=, :cache

      def initialize maximum_age: MAXIMUM_AGE, logger: nil
        self.maximum_age = maximum_age.to_i
        self.logger = logger || NullLogger.instance
        self.cache = {}
      end

      def get key, prefix: SHARED_PREFIX
        evict_expired_keys
        k = generation_key(key, prefix)
        logger.debug { "Getting #{k.inspect} (key: #{key.inspect}, prefix: #{prefix.inspect})" }
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

      def set key, value, prefix: SHARED_PREFIX
        evict_expired_keys
        k = generation_key(key, prefix)
        logger.debug { "Setting #{k.inspect} (key: #{key.inspect}, prefix: #{prefix.inspect}) to #{value.inspect}" }
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

      def generation_key key, prefix
        [ generation_id, prefix, key ].join(KEY_DIVIDER)
      end
    end
  end
end
