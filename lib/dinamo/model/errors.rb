module Dinamo
  class Model
    class Errors < ::Hash
      def add(attribute, message)
        fetch(attribute) { self[attribute] = [] } << message
      end

      def count
        values.inject(0) { |all, value| all + value.length }
      end

      def empty?
        count.zero?
      end
    end
  end
end
