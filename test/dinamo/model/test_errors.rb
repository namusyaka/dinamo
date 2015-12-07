require 'helper'
require 'support/dinamo/database'

class TestErrors < Test::Unit::TestCase
  setup do
    @errors = Dinamo::Model::Errors.new
    @message = "Raised an error"
    @attribute = :foo
  end

  sub_test_case "#add" do
    setup { @errors.add(@attribute, @message) }
    test "should add attribute and message correctly" do
      assert { @errors[@attribute] == [@message] }
    end
  end

  sub_test_case "#count" do
    setup { @errors.add(@attribute, @message) }
    test "should return the count correctly" do
      assert { @errors.count == 1 }
    end
  end

  sub_test_case "#empty?" do
    test "should return true if errors are empty" do
      assert { @errors.empty? }
    end
  end
end
