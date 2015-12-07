require 'helper'
require 'support/dinamo/database'

class TestDirty < Test::Unit::TestCase
  def self.model
    Ghana
  end

  setup { @instance = Dinamo::Model.new(foo: "bar") }

  sub_test_case "#changed?" do
    sub_test_case "when instance has no changes" do
      test "should return false" do
        assert { not @instance.changed? }
      end
    end

    sub_test_case "when instance has changes" do
      setup { @instance.foo = "hey" }
      test "should return true" do
        assert { @instance.changed? }
      end
    end
  end

  sub_test_case "#changed" do
    sub_test_case "when instance has no changes" do
      test "should return an empty array" do
        assert { @instance.changed.kind_of?(Array) }
        assert { @instance.changed.empty? }
      end
    end

    sub_test_case "when instance has changes" do
      setup { @instance.foo = "hey" }
      test "should return changed keys as an array" do
        assert { @instance.changed == ["foo"] }
      end
    end
  end

  sub_test_case "#changes" do
    sub_test_case "when instance has no changes" do
      test "should return an empty hash" do
        assert { @instance.changes.kind_of?(Hash) }
        assert { @instance.changes.empty? }
      end
    end

    sub_test_case "when instance has changes" do
      setup { @instance.foo = "hey" }
      test "should return changed keys as an hash" do
        assert { @instance.changes == { "foo" => ["bar", "hey"] } }
      end
    end
  end

  sub_test_case "#attribute_changed?" do
    sub_test_case "when passed attribute name doesn't exist" do
      test "should return false" do
        assert { not @instance.attribute_changed?(:howl) }
      end
    end

    sub_test_case "when passed attribute name isn't changed" do
      test "should return false" do
        assert { not @instance.attribute_changed?(:foo) }
      end
    end

    sub_test_case "when passed attribute name is changed" do
      setup { @instance.foo = "baz" }
      test "should return true" do
        assert { @instance.attribute_changed?(:foo) }
      end
    end
  end
end
