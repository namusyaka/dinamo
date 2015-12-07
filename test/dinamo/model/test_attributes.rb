require 'helper'
require 'support/dinamo/database'

class TestAttributes < BaseTestCase
  def self.model
    Ghana
  end

  sub_test_case "#attributes=" do
    sub_test_case "when attributes contains unexistence fields" do
      setup do
        @instance = build_dinamo(klass: Ghana)
        @new_attributes = { unexistence_attribute: true }
        @instance.attributes = @new_attributes
      end

      test "should define new attribute method" do
        assert { @instance.respond_to?(:unexistence_attribute) }
      end

      test "should merge #attributes with new attributes" do
        assert do
          @new_attributes.all? do |key, val|
            @instance.attributes[key] && @instance.attributes[key] == val
          end
        end
      end

      test "should abort if instance is already persisted and attributes is primary key" do
        stub(@instance).persisted? { true }
        assert_raise Dinamo::Exceptions::PrimaryKeyError do
          @instance.attributes = { id: 1234 }
        end
      end
    end

    sub_test_case "when attributes contains existence fields" do
      setup do
        @instance = build_dinamo(klass: Ghana, pocky: "like")
      end

      test "should override correctly" do
        @instance.attributes = { pocky: "love" }
        assert { @instance.pocky == "love" }
      end
    end
  end

  sub_test_case "#==" do
    sub_test_case "when two attributes are equivalence" do
      setup do
        @a = build_dinamo(klass: Ghana, id: 123)
        @b = build_dinamo(klass: Ghana, id: 123)
      end

      test "should be truthy" do
        assert { @a == @b }
      end
    end

    sub_test_case "when two attributes are non-equivalence" do
      setup do
        @a = build_dinamo(klass: Ghana)
        @b = build_dinamo(klass: Ghana)
      end

      test "should be falsey" do
        assert { @a != @b }
      end
    end
  end

  sub_test_case "#[]" do
    setup do
      @instance = build_dinamo(klass: Ghana, foo: "hello")
    end

    sub_test_case "when passed key exists" do
      test "should return value by associated key" do
        assert { @instance[:foo] == "hello" }
      end

      test "should return value by associated key even if key is string" do
        assert { @instance["foo"] == "hello" }
      end
    end

    sub_test_case "when passed key doesn't exist" do
      test "should return nil" do
        assert { @instance[:unexistence_attribute].nil? }
      end
    end
  end

  sub_test_case "#[]=" do
    setup do
      @instance = build_dinamo(klass: Ghana, foo: "hello")
    end

    sub_test_case "when passed key exists" do
      test "should override value by associated key" do
        @instance[:foo] = "hi"
        assert { @instance[:foo] == "hi" }
      end

      test "should override value by associated key even if key is string" do
        @instance["foo"] = "ho"
        assert { @instance[:foo] == "ho" }
      end
    end

    sub_test_case "when passed key doesn't exist" do
      test "should define new attribute method and set it correctly" do
        @instance[:unexistence] = true
        assert { @instance[:unexistence] == true }
        assert { @instance.unexistence   == true }
      end
    end
  end
end
