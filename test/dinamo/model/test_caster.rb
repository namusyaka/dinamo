require 'helper'
require 'support/dinamo/database'

class TestCaster < Test::Unit::TestCase
  def self.model
    Ghana
  end

  setup do
    @caster = Dinamo::Model::Caster.new
    @caster.register(:string) { |v| v.to_s }
  end

  sub_test_case "#register" do
    sub_test_case "when original case" do
      test "should register passed type and block association" do
        assert { @caster.supported_type?(:string) }
      end
    end

    sub_test_case "when passed type is duplicated" do
      setup do
        @caster.register(:string) { |v| "string: #{v}" }
        @caster.associate(:foo, :string)
      end

      test "should override the block by specifing passed type" do
        assert { @caster.supported_type?(:string) }
        assert { @caster.supported_types.size == 1 }
        assert { @caster.cast(foo: :howl) == { foo: "string: howl" } }
      end
    end
  end

  sub_test_case "#associate" do
    sub_test_case "when passed type is supported" do
      test "should associate passed key with type" do
        assert do
          @caster.associate(:foo, :string) == [:foo] &&
            @caster.types[:string].supported_key?(:foo)
        end
      end
    end

    sub_test_case "when passed type isn't supported" do
      test "should associate passed key with type" do
        assert_raise Dinamo::Exceptions::UnsupportedTypeError do
          @caster.associate(:foo, :unsupported_type)
        end
      end
    end
  end

  sub_test_case "#cast" do
    sub_test_case "when containing hash which requires casting" do
      setup { @caster.associate(:bar, :string) }
      test "should cast values correctly" do
        assert do
          @caster.cast(foo: "foo", bar: 1234) == { foo: "foo", bar: "1234" }
        end
      end
    end

    sub_test_case "when containing hash which doensn't require casting" do
      setup { @caster.associate(:baz, :string) }
      test "should not cast values" do
        assert do
          @caster.cast(foo: "foo", bar: 1234) == { foo: "foo", bar: 1234 }
        end
      end
    end
  end
end
