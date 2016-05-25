module Dinamo
  class Model
    module Persistence
      extend ActiveSupport::Concern

      included do
        after(:save) { @new_record = !errors.empty? }
        after(:initialize) { |**opts| self.new_record = true }
      end

      module ClassMethods
        def get(**keys)
          get!(**keys) rescue nil
        end

        def get!(**keys)
          item = adapter.get(**keys).item 
          fail Exceptions::RecordNotFoundError,
            "Corresponding record (%p) can not be found" % keys unless item
          object = new(**symbolize(item))
          object.new_record = false
          object
        end

        def partition(**conditions)
          partition!(**conditions) rescue nil
        end

        def partition!(**conditions)
          items = adapter.partition(**conditions).items
          fail Exceptions::RecordNotFoundError,
            "Corresponding record (%p) can not be found" % conditions if items.empty?
          items.map do |item|
            object = new(**symbolize(item))
            object.new_record = false
            object
          end
        end

        def exist?(**keys)
          adapter.exist?(**keys)
        end

        def create(attributes = nil, &block)
          object = new(**attributes, &block)
          object.new_record = true
          object.with_callback :create do
            object.save
            object
          end
        end

        def create!(attributes = nil, &block)
          object = new(**attributes, &block)
          object.new_record = true
          object.with_callback :create do
            object.save!
            object
          end
        end

        def symbolize(attrs)
          attrs.each_with_object({}) do |(key, val), new_attrs|
            new_attrs[key.to_sym] = val
          end
        end
      end

      def new_record=(bool)
        @new_record = bool
      end

      def new_record?
        @new_record
      end

      def destroy
        returned_value =
          if persisted?
            self.class.adapter.delete(primary_keys)
            true
          else
            false
          end
        (@destroyed = true) && freeze
        returned_value
      end

      def destroyed?
        !!@destroyed
      end

      def persisted?
        !(new_record? || destroyed?)
      end

      def save(*args)
        !!save!(*args)
      rescue Exceptions::ValidationError
        false
      end

      def save!(*args)
        with_callback :save, *args do
          !!create_or_update(*args)
        end
      end

      def create_or_update(*args)
        new_record? ? create_record(*args) : update_record(*args)
      end

      def create_record(validate: true)
        if !validate || valid?
          self.class.adapter.insert(**self.class.symbolize(attributes))
          self.new_record = false
          self
        else
          fail Exceptions::ValidationError
        end
      end

      def transaction(&block)
        returned_value = block.call
        unless returned_value
          silent_assign(previous_attributes)
          clear_previous_attributes
        end
        returned_value
      end

      def update(validate: false, **new_attributes)
        transaction do
          with_callback :update do
            self.attributes = new_attributes
            return save if changed?
            true
          end
        end
      rescue Exceptions::PrimaryKeyError
        false
      end

      def update!(validate: false, **new_attributes)
        transaction do
          with_callback :update do
            self.attributes = new_attributes
            return save! if changed?
            true
          end
        end
      end

      def update_record(validate: true)
        if !validate || valid?
          symbolized = self.class.symbolize(variable_attributes)
          updated_object = self.class.adapter.update(primary_keys, **symbolized)
          self.attributes = updated_object.attributes
        else
          fail Exceptions::ValidationError
        end
      end

      def reload!
        fresh_object = self.class.get(primary_keys)
        @attributes = fresh_object.instance_variable_get(:'@attributes')
        @new_record = false
        self
      end
    end
  end
end
