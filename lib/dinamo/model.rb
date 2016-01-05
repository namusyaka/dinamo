require 'active_support/concern'
require 'dinamo/adapter'
require 'dinamo/exceptions'
require 'dinamo/model/callback'
require 'dinamo/model/validation'
require 'dinamo/model/validator'
require 'dinamo/model/attributes'
require 'dinamo/model/persistence'
require 'dinamo/model/dirty'

module Dinamo
  class Model
    include Callback
    include Validation
    include Attributes
    include Persistence
    include Dirty

    extend Dinamo::Adapter::Glue

    class << self
      def default_casters(&block)
        @default_casters ||= block
      end

      def inherited(klass)
        klass.callbacks.merge!(callbacks)
        klass.class_eval &default_casters
      end

      def table_name
        @table_name ||= self.name.split(/::/).last.underscore.pluralize
      end

      def table_name=(name)
        @table_name = name
      end

      def strict(bool)
        @strict = bool
      end

      def strict?
        @strict.nil? ? true : @strict
      end
    end

    default_casters do
      cast(:list)       { |v| Array(v)           }
      cast(:string)     { |v| v.to_s             }
      cast(:number)     { |v| v.to_i             }
      cast(:binary)     { |v| Array(v).pack(?m)  }
      cast(:boolean)    { |v| !!v                }
      cast(:number_set) { |v| Array(v).map(&:to_i) }
      cast(:string_set) { |v| Array(v).map(&:to_s) }
      cast(:binary_set) { |v| Array(v).map { |t| Array(t.to_s).pack(?m) } }
    end

    def initialize(**attributes, &block)
      with_callback :initialize, **attributes do
        block.call(self) if block_given?
      end
    end
  end
end
