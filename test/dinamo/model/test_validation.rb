require 'helper'
require 'support/dinamo/database'

class TestValidation < BaseTestCase

  class User < Dinamo::Model
    hash_key :id, type: :number
    range_key :type, type: :string
    validates_presence_of :id
  end

  def self.model
    Ghana
  end

  sub_test_case "#valid?" do
    sub_test_case "when instance is valid" do
      setup do
        @instance = build_dinamo(klass: User, id: 1234)
      end

      test "should return true" do
        assert { @instance.valid? }
      end
    end

    sub_test_case "when instance is not valid" do
      setup do
        @instance = build_dinamo(klass: User, id: nil)
      end

      test "should return false" do
        assert { not @instance.valid? }
      end
    end
  end
end
