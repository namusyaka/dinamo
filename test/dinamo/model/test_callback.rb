require 'helper'
require 'support/dinamo/database'

class TestCallback < Test::Unit::TestCase
  def self.model
    Ghana
  end

  reset_callback = Proc.new do
    @callback = Class.new
    @callback.send(:include, Dinamo::Model::Callback)
  end

  setup &reset_callback
  cleanup &reset_callback

  sub_test_case ".on" do
    setup do
      @block = Proc.new {}
      @callback.on(:before, :foo, &@block)
    end

    test "should set block correctly" do
      assert do
        @callback.callbacks[:before][:foo].include?(@block)
      end
    end
  end

  sub_test_case "#invoke_callbacks" do
    setup do
      @instance = @callback.new
      stub(@instance).count { @count ||= [] }
      @callback.before(:foo) { self.count << "hello" }
      @instance.invoke_callbacks(:before, :foo)
    end

    test "should invoke block registered by using .on or its syntax-sugars" do
      assert { @instance.count.include?("hello")  }
    end
  end

  sub_test_case "#with_callback" do
    setup do
      @instance = @callback.new
      stub(@instance).count { @count ||= [] }
      @callback.before(:foo) { self.count << "foo" }
      @callback.after(:foo) { self.count << "baz" }
      @instance.with_callback(:foo) { @instance.count << "bar" }
    end

    test "should invoke before and after callbacks correctly" do
      assert { @instance.count == ["foo", "bar", "baz"] }
    end
  end
end
