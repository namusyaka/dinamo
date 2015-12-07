module Dinamo
  module Test
    module Database
      def startup
        rewinder = Rewinder.new(model)
        rewinder.create_table unless rewinder.exist?
      end

      def shutdown
        rewinder = Rewinder.new(model)
        rewinder.drop_table if rewinder.exist?
      end

      class Rewinder
        PROVISIONED_THROUGHPUT = {
          read_capacity_units: 1,
          write_capacity_units: 1
        }

        def initialize(klass)
          @klass = klass
        end

        def create_table
          table_name = @klass.table_name
          client.create_table(
            table_name: table_name,
            **extract_params(@klass)) unless exist?
        end

        def drop_table
          client.delete_table(table_name: @klass.table_name)
        end

        def exist?
          table_name = @klass.table_name
          client.list_tables.table_names.include?(table_name)
        end

        private

        def client
          Aws::DynamoDB::Client.new(endpoint: "http://localhost:8000")
        end

        def extract_params(klass)
          key_schema = klass.primary_keys.each_with_object([]) do |(key ,val), key_schema|
            schema = { attribute_name: val, key_type: key.to_s.upcase }
            key_schema << schema
          end
          attribute_definitions = klass.supported_fields.each_with_object([]) do |key, definitions|
            if key.primary?
              definitions << { attribute_name: key.name, attribute_type: serialize_type(key.type) }
            end
          end
          { key_schema: key_schema,
            attribute_definitions: attribute_definitions,
            provisioned_throughput: PROVISIONED_THROUGHPUT }
        end

        def serialize_type(type)
          case type
          when :string  then "S"
          when :number  then "N"
          when :boolean then "B"
          end
        end
      end
    end
  end
end
