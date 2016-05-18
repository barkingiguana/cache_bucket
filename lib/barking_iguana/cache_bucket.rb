require "barking_iguana/cache_bucket/version"
require "barking_iguana/cache_bucket/cache_bucket"
require "barking_iguana/cache_bucket/dsl"

module BarkingIguana
  module CacheBucket
    class << self
      attr_accessor :logger
    end
    self.logger = NullLogger.instance

    class << self
      attr_accessor :maximum_age
    end
    self.maximum_age = 3600

    def self.get name, options = {}
      buckets[name] ||= create_bucket name, options
    end

    def self.buckets
      @bucket ||= {}
    end
    private_class_method :buckets

    def self.create_bucket name, options
      o = options.dup
      o[:logger] ||= logger
      o[:maximum_age] ||= maximum_age
      CacheBucket.new o
    end
  end
end
