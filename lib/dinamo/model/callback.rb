module Dinamo
  class Model
    module Callback
      extend ActiveSupport::Concern

      def with_callback(kind, *args, &block)
        invoke_callbacks(:before, kind, *args)
        block.call
      ensure
        invoke_callbacks(:after, kind, *args)
      end

      def invoke_callbacks(type, kind, *args)
        ref = respond_to?(:callbacks) ? callbacks : self.class.callbacks
        current = ref[type][kind]
        return unless current
        current.each { |callback| instance_exec(*args, &callback) }
      end

      module ClassMethods
        def on(type, kind, &callback)
          (callbacks[type][kind] ||= []) << callback
        end

        def before(kind, &callback)
          on(:before, kind, &callback)
        end

        def after(kind, &callback)
          on(:after, kind, &callback)
        end

        def callbacks
          @callbacks ||= { before: {}, after: {} }
        end
      end
    end
  end
end
