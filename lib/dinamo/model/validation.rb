require 'dinamo/model/errors'
require 'dinamo/model/validator'

module Dinamo
  class Model
    module Validation
      extend ActiveSupport::Concern

      def valid?
        validate
      end

      def errors
        @errors ||= Dinamo::Model::Errors.new
      end

      def validate
        errors.clear
        validate_unsupported_fields
        validate_required_attributes
        validate_by_using_validators
        errors.empty?
      end

      private

      def validate_by_using_validators
        self.class.validators.each do |validator|
          validator.validate(self)
        end
      end

      def validate_unsupported_fields
        supported_fields = self.class.supported_fields.map(&:name)
        attributes.each do |(attr, _)|
          unless supported_fields.include?(attr.to_s)
            message =  "%p attribute is not supported" % [attr, self.class]
            errors.add(attr, message)
          end
        end
      end

      def validate_required_attributes
        self.class.required_fields.map(&:name).each do |attr|
          message = "%p attribute is required" % attr
          errors.add(attr, message) unless attributes.has_key?(attr)
        end
      end
    end
  end
end
