require 'delegate'

module Dinamo
  class Model
    class Caster
      attr_reader :types

      def initialize
        @types = {}
      end

      def register(type, &block)
        @types[type] = Any.new(type, &block)
      end

      def cast(attributes)
        attributes.each_with_object({}) do |(key, value), casted|
          casted[key] =
            if found = @types.find { |_, any| any.supported_key?(key) }
              found.pop.cast(value)
            else
              value
            end
        end
      end

      def supported_type?(type)
        supported_types.include?(type)
      end

      def supported_types
        @types.keys
      end

      def associate(key, type)
        fail Exceptions::UnsupportedTypeError,
          "%p type is not supported" % type unless @types.keys.include?(type)
        current = @types[type]
        current.support(key)
      end

      class Any
        def initialize(type, &block)
          @type = type
          @block = block
        end

        def cast(value)
          case @block.arity
          when 0 then @block.call
          when 1 then @block.call(value)
          when 2 then @block.call(@type, value)
          end
        rescue
          fail Exceptions::CastError,
            "%p can not be casted into %p" % [value, @type]
        end

        def support(key)
          keys << key.to_sym unless supported_key?(key)
        end

        def supported_key?(key)
          keys.include?(key.to_sym)
        end

        private

        def keys
          @keys ||= []
        end
      end
    end
  end
end
