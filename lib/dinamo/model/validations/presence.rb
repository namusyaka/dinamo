class Dinamo::Model
  module Validation
    class PresenceValidator < EachValidator
      def validate_each(record, key, value)
        #p record
        #p key
        #p value
        record.errors.add(key, :blank) if value.blank?
      end
    end

    module ClassMethods
      def validates_presence_of(*args)
        validates_with PresenceValidator, adjust_validator_options(*args)
      end
    end
  end
end
