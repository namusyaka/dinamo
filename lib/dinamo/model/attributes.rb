require 'active_support/core_ext/hash/indifferent_access'
require 'dinamo/model/caster'

module Dinamo
  class Model
    module Attributes
      extend ActiveSupport::Concern

      included do
        before(:save) { self.attributes = self.class.caster.cast(attributes) }
        after(:save) { changes_applied }

        before :initialize do |**attributes|
          @attributes = {}.with_indifferent_access
          silent_assign(**attributes)
          self.class.define_attribute_methods(*attributes.keys)
        end
        after(:initialize) do
          @attributes = self.class.default_values.merge(@attributes)
        end

        before :attribute_update do |attribute, value|
          pkey = primary_keys[attribute]
          if persisted? && pkey && pkey != value
            raise Exceptions::PrimaryKeyError, "%p cannot be modified" % attribute
          end
        end
      end

      module ClassMethods
        def attribute_methods
          @attribute_names ||= []
        end

        def attribute_method?(attr)
          attribute_methods.include?(attr)
        end

        def attribute_method_already_implemented?(attr)
          attribute_method?(attr) && respond_to?(attr) && respond_to?("#{attr}=")
        end

        def define_attribute_methods(*attrs)
          attrs.each { |attr| define_attribute_method(attr) }
        end

        def define_attribute_method(attr)
          return if attribute_method_already_implemented?(attr)
          define_method(attr) { @attributes[attr] }
          define_method("#{attr}=") do |val|
            with_callback :attribute_update, attr, val do
              @attributes[attr] = val
            end
          end
          attribute_methods << attr
        end

        def default_values
          Hash[supported_fields.select(&:default).
            map { |field| [field.name, field.default] }].with_indifferent_access
        end

        def primary_keys
          @primary_keys ||= {}
        end

        def primary_key(kind, key, type: nil, **options)
          name = :"@#{kind}_key"
          var = instance_variable_get(name)
          primary_keys[kind] = key
          var ? var : instance_variable_set(name, key.to_s)
          define_attribute_method key
          supported_fields << Key.new(key.to_s, type: type, required: true, primary: true)
        end

        def supported_fields
          @supported_fields ||= []
        end

        def required_fields
          supported_fields.select(&:required?)
        end

        def field(key, type: nil, **options)
          caster.associate(key, type) if type
          supported_fields << Key.new(key.to_s, type: type, **options)
          define_attribute_method(key) unless respond_to?(:"#{key}=")
        end

        def hash_key(key, **options)
          primary_key :hash, key, **options
        end

        def range_key(key, **options)
          primary_key :range, key, **options
        end

        def caster
          @caster ||= Caster.new
        end

        def cast(type, &block)
          caster.register(type, &block)
        end
      end

      attr_reader :attributes

      def [](key)
        attributes[key]
      end

      def []=(key, value)
        self.attributes = { key => value }
      end

      def variable_attributes
        keys = primary_keys.keys
        attributes.select { |key, _| !keys.include?(key.to_sym) }
      end

      def attributes=(attrs)
        attrs.each_pair do |key, val|
          name = "#{key}="
          self.class.define_attribute_method(key) unless respond_to?(name)
          send(name, val)
        end
      end

      def hash_key
        attributes[self.class.primary_keys[:hash]]
      end

      def range_key
        attributes[self.class.primary_keys[:range]]
      end
      
      def silent_assign(new_attributes)
        @attributes.merge!(new_attributes)
      end

      def ==(other)
        return false unless other.kind_of?(Dinamo::Model)
        hash_key == other.hash_key && range_key == other.range_key
      end
      alias equal? ==

      def primary_keys
        @primary_keys ||= self.class.primary_keys.inject({}) do |keys, (_, key)|
          keys.merge(key => attributes[key])
        end
      end

      class Key
        attr_reader :name, :type, :default

        def initialize(name, type: nil, required: false, primary: false, default: nil, **options)
          @name     = name
          @type     = type
          @required = required
          @primary  = primary
          @default  = default
        end

        def required?
          @required
        end

        def primary?
          @primary
        end
      end
    end
  end
end
