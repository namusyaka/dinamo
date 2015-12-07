module Dinamo
  class Model
    module Dirty
      extend ActiveSupport::Concern

      included do
        before :attribute_update do |attr, val|
          previous_attribute = @attributes[attr]
          unless previous_attribute == val
            changed_attributes[attr]  = val
            previous_attributes[attr] = previous_attribute
          end
        end
        after(:save) { changes_applied }
      end

      def changed
        changed_attributes.keys
      end

      def changed?
        !changed_attributes.empty?
      end

      def changes
        map = changed.map { |attr| [attr, attribute_change(attr)] }
        ActiveSupport::HashWithIndifferentAccess[map]
      end

      def changed_attributes
        @changed_attributes ||= ActiveSupport::HashWithIndifferentAccess.new
      end

      def attribute_changed?(attr)
        changed.include?(attr.to_s)
      end

      def changes_applied
        @previously_changed = changes
        @changed_attributes = ActiveSupport::HashWithIndifferentAccess.new
      end

      def clear_changes_information
        @previously_changed = ActiveSupport::HashWithIndifferentAccess.new
        @changed_attributes = ActiveSupport::HashWithIndifferentAccess.new
      end

      def clear_previous_attributes
        @previously_changed = ActiveSupport::HashWithIndifferentAccess.new
      end

      private

      def attribute_change(attr)
        return unless attribute_changed?(attr)
        [previous_attributes[attr], changed_attributes[attr]]
      end

      def previous_attributes
        @previous_attributes ||= ActiveSupport::HashWithIndifferentAccess.new
      end
    end
  end
end
