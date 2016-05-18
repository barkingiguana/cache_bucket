module BarkingIguana
  module CacheBucket
    # Include this DSL in classes where you'd like to easily access a
    # `CacheBucket` instance named after the class it's being included into.
    #
    # In each class and instance of that class you'll get access to a
    # `cache_bucket` method to provide access to a `CacheBucket`.
    #
    #
    #    class Example
    #      def self.class_method
    #        cache_bucket.get 'foo' do
    #          'bar_set_in_class_method'
    #        end
    #      end
    #
    #      def instance_method
    #        puts cache_bucket.get 'foo'
    #      end
    #    end
    #
    # Given the above class definition, here's some example output:
    #
    #    Example.class_method
    #    Example.new.instance_method #=> 'bar_set_in_class_method'
    #
    # It's hard to imagine a place where you'll actually want to use the
    # instance variable of this, and it may be removed in future releases.
    module DSL
      def self.included into
        into.extend ClassMethods
        into.include InstanceMethods
      end

      module InstanceMethods
        # Access the Cache Bucket for thisinstances class.
        def cache_bucket options = {}
          BarkingIguana::CacheBucket.get self.class.name, options
        end
      end

      module ClassMethods
        # Access the Cache Bucket for this class.
        def cache_bucket options = {}
          BarkingIguana::CacheBucket.get name, options
        end
      end
    end
  end
end
