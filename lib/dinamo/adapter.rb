require 'dinamo/exceptions'
require 'aws-sdk-dynamodb'

module Dinamo
  class Adapter
    module Glue
      def adapter_options
        @adapter_options ||= {}
      end

      def adapter
        @adapter ||= {}
        @adapter[table_name] ||= Dinamo::Adapter.new(table_name: table_name, **adapter_options)
      end
    end

    def initialize(table_name: nil, **options)
      @options    = options
      @database   = Aws::DynamoDB::Client.new
      @table_name = table_name
    end

    def get(**keys)
      @database.get_item(table_name: @table_name, key: keys)
    rescue
      handle_error! $!
    end

    def partition(conditions)
      @database.query(
        table_name: @table_name,
        key_conditions: make_key_conditions(**conditions)
      )
    rescue
      handle_error! $!
    end

    def insert(**keys)
      @database.put_item(
        table_name: @table_name,
        item: keys,
        return_values: "ALL_OLD"
      )
    rescue
      handle_error! $!
    end

    def update(key, attributes)
      find_or_abort!(**key)
      @database.update_item(
        table_name: @table_name,
        key: key,
        attribute_updates: serialize_attributes(attributes),
        return_values: "ALL_NEW"
      )
    rescue
      handle_error! $!
    end

    def delete(key)
      find_or_abort!(**key)
      @database.delete_item(
        table_name: @table_name,
        key: key
      )
    end

    def serialize_attributes(attributes)
      attributes.each_with_object({}) do |(key, value), new_attributes|
        new_attributes[key] = { value: value, action: "PUT" }
      end
    end

    def exist?(**keys)
      !!get(**keys).item rescue false
    end

    private

    def find_or_abort!(**key)
      item = get(**key)
      fail Exceptions::RecordNotFoundError,
        "Corresponding record (%p) can not be found" % key unless item && item.item
      item
    end

    def handle_error!(evar)
      case evar
      when Aws::DynamoDB::Errors::ValidationException
        fail Dinamo::Exceptions::ValidationError, evar.message
      when Aws::DynamoDB::Errors::ResourceNotFoundException
        fail Dinamo::Exceptions::ResourceNotFoundError, evar.message
      else
        fail evar, evar.message
      end
    end

    def make_key_conditions(**conditions)
      conditions.each_with_object({}) do |(key, val), serialized|
        serialized[key.to_s] = {
          attribute_value_list: val === Array ? val : Array(val),
          comparison_operator: "EQ"
        }
      end
    end
  end
end
