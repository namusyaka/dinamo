require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/object/blank'

class Dinamo::Model
  module Validation
    class Validator
      attr_reader :options

      def initialize(**options, &block)
        @options = options || {}
        @block = block
      end

      def validate(record)
        raise NotImplementedError
      end
    end

    class EachValidator < Validator
      attr_reader :attributes

      def initialize(attributes: [], **options)
        @attributes = attributes
        raise ArgumentError, ":attributes cannot be blank" if @attributes.empty?
        super
      end

      def validate(record)
        attributes.each do |key, val|
          value = record[key]
          next if (value.nil? && options[:allow_nil]) ||
            (value.blank? && options[:allow_blank])
          validate_each(record, key, value)
        end
      end

      def validate_each(record, attribute, value)
        raise NotImplementedError
      end
    end

    module ClassMethods
      def validates_with(*args, &block)
        options = args.extract_options!
        options[:class] = self

        args.each do |validator_class|
          validator = validator_class.new(options, &block)

          if validator.respond_to?(:attributes) && !validator.attributes.empty?
            validator.attributes.each do |attribute|
              _validators[attribute.to_sym] << validator
            end
          else
            _validators[nil] << validator
          end
        end
      end

      def validators
        _validators.values.flatten.uniq
      end

      def _validators
        @_validators ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def adjust_validator_options(*args)
        options = args.extract_options!.symbolize_keys
        args.flatten!
        options[:attributes] = args
        options
      end
    end
  end

  require 'dinamo/model/validations/presence'
end
