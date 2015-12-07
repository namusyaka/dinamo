require 'helper'
require 'support/models/ghana'
require 'support/dinamo/database'

class TestAdapter < BaseTestCase
  extend Dinamo::Test::Database
  def self.model
    Ghana
  end

  sub_test_case "#get" do
    setup do
      @adapter = Dinamo::Adapter.new(table_name: 'dinamo_tests')
      @primary_keys = make_primary_keys(klass: Ghana)
      @adapter.insert @primary_keys
    end

    sub_test_case "when passed key matches with existing record" do
      test "should return response correctly" do
        assert do
          @adapter.get(@primary_keys).kind_of? Seahorse::Client::Response
        end
      end
    end

    sub_test_case "when passed key doesn't matches with existing records" do
      test "should return an instance of Seahorse::Client::Response" do
        assert do
          @adapter.get(id: 2, type: "b").kind_of? Seahorse::Client::Response
        end
      end
    end

    sub_test_case "when passed key is invalid" do
      test "should raise ValidationError" do
        assert_raise Dinamo::Exceptions::ValidationError do
          @adapter.get(id: "1", type: 0)
        end
      end
    end
  end

  sub_test_case "#exist?" do
    setup do
      @adapter = Dinamo::Adapter.new(table_name: 'dinamo_tests')
      @primary_keys = make_primary_keys(klass: Ghana)
      @adapter.insert @primary_keys
    end

    sub_test_case "normal system" do
      test "should return true if passed key matches with exsiting records" do
        assert { @adapter.exist?(@primary_keys) }
      end

      test "should return false if passed key doesn't matches with exsiting records" do
        assert { not @adapter.exist?(id: 10000, type: "c") }
      end

      test "should return false even if passed key is invalid" do
        assert { not @adapter.exist?(id: "10000", type: 1) }
      end
    end
  end

  sub_test_case "#insert" do
    setup do
      @adapter = Dinamo::Adapter.new(table_name: 'dinamo_tests')
      @primary_keys = make_primary_keys(klass: Ghana)
      @adapter.insert @primary_keys
    end

    sub_test_case "normal system" do
      test "should return true if passed key matches with exsiting records" do
        assert { @adapter.exist?(@primary_keys) }
      end

      test "should return false if passed key doesn't matches with exsiting records" do
        assert { not @adapter.exist?(id: 10000, type: "c") }
      end

      test "should return false even if passed key is invalid" do
        assert { not @adapter.exist?(id: "10000", type: 1) }
      end
    end
  end

  sub_test_case "#update" do
    setup do
      @adapter = Dinamo::Adapter.new(table_name: 'dinamo_tests')
      @primary_keys = make_primary_keys(klass: Ghana)
      @adapter.insert @primary_keys
    end

    sub_test_case "normal system" do
      test <<-EOS do
        should return an instance of Seahorse::Client::Response
          if passed key matches with exsiting records
      EOS
        assert do
          result = @adapter.update(@primary_keys, ruby: "is so cool")
          result.kind_of? Seahorse::Client::Response
        end
      end

      test <<-EOS do
        should return an instance of Seahorse::Client::Response
          if passed key doesn't matches with exsiting records
      EOS
        assert_raise Dinamo::Exceptions::RecordNotFoundError do
          pkey = @primary_keys.merge(type: 'hogefuga')
          @adapter.update(pkey, ruby: "is so cool")
        end
      end
    end

    sub_test_case "abnormal system" do
      test <<-EOS do
        should raise ValidationError even if passed key is invalid
      EOS
        assert_raise Dinamo::Exceptions::ValidationError do
          @adapter.update({ id: "10000", type: 1 }, { ruby: "is so cool" })
        end
      end
    end
  end
end
