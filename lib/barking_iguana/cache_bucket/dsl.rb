module BarkingIguana
  module CacheBucket
    module DSL
      def self.included into
        into.extend ClassMethods
        into.include InstanceMethods
      end

      module InstanceMethods
        def class_cache options = {}
          BarkingIguana::CacheBucket.get self.class.name, options
        end
      end

      module ClassMethods
        def class_cache options = {}
          BarkingIguana::CacheBucket.get name, options
        end
      end
    end
  end
end
