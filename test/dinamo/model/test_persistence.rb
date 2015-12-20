require 'helper'
require 'support/dinamo/database'

class TestPersistence < BaseTestCase
  extend Dinamo::Test::Database
  def self.model
    Ghana
  end

  setup { @instance = build_dinamo(klass: Ghana, foo: "bar") }

  sub_test_case ".create" do
    sub_test_case "when instance is created successfully" do
      setup do
        @attributes = { foo: "hello" }
        @instance = create_dinamo(klass: Ghana, **@attributes)
      end

      test "should be a kind of Dinamo::Model" do
        assert { @instance.kind_of?(Dinamo::Model) }
      end

      test "should be persisted" do
        assert { @instance.persisted? }
      end
    end

    sub_test_case "when instance is created unsuccessfully" do
      setup do
        @attributes = { foo: "hello", baz: "hi" }
        @instance = create_dinamo(klass: Ghana, **@attributes)
      end

      test "should be a kind of Dinamo::Model" do
        assert { @instance.kind_of?(Dinamo::Model) }
      end

      test "should not be persisted" do
        assert { not @instance.persisted? }
      end
    end
  end

  sub_test_case ".create!" do
    sub_test_case "when instance is created successfully" do
      setup do
        @attributes = { foo: "hello" }
        @instance = create_dinamo!(klass: Ghana, **@attributes)
      end

      test "should be a kind of Dinamo::Model" do
        assert { @instance.kind_of?(Dinamo::Model) }
      end

      test "should be persisted" do
        assert { @instance.persisted? }
      end
    end

    sub_test_case "when instance is created unsuccessfully" do
      setup do
        @attributes = { foo: "hello", baz: "hi" }
      end

      test "should abort" do
        assert_raise Dinamo::Exceptions::ValidationError do
          create_dinamo!(klass: Ghana, **@attributes)
        end
      end
    end
  end
  sub_test_case ".exist?" do
    sub_test_case "when matched record exists" do
      setup do
        @attributes = { foo: "hello" }
        @expected   = create_dinamo(klass: Ghana, **@attributes)
      end

      test "should get a record" do
        assert { Ghana.exist?(**@expected.primary_keys) }
      end
    end

    sub_test_case "when matched record doesn't exists" do
      setup { @attributes = { foo: "hello" } }

      test "should not get a record" do
        assert { not Ghana.exist?(**@attributes) }
      end
    end
  end

  sub_test_case ".get" do
    sub_test_case "when matched record exists" do
      setup do
        @attributes = { foo: "hello" }
        @expected   = create_dinamo(klass: Ghana, **@attributes)
      end

      test "should get a record" do
        assert { @expected == Ghana.get(**@expected.primary_keys) }
      end
    end

    sub_test_case "when matched record doesn't exists" do
      setup { @attributes = { foo: "hello" } }

      test "should not get a record" do
        assert { Ghana.get(**@attributes).nil? }
      end
    end
  end

  sub_test_case ".get!" do
    sub_test_case "when valid keys are given, and matched record exists" do
      setup do
        @attributes = { foo: "hello" }
        @expected   = create_dinamo(klass: Ghana, **@attributes)
      end

      test "should get a record" do
        assert { @expected == Ghana.get!(**@expected.primary_keys) }
      end
    end

    sub_test_case "when valid keys are given, but matched record doesn't exists" do
      setup { @attributes = { foo: "hello" } }

      test "should not get a record" do
        assert_raise Dinamo::Exceptions::RecordNotFoundError do
          Ghana.get!(id: 1234, type: "______")
        end
      end
    end

    sub_test_case "when invalid keys are given" do
      setup { @attributes = { foo: "hello" } }

      test "should not get a record" do
        assert_raise Dinamo::Exceptions::ValidationError do
          Ghana.get!(**@attributes)
        end
      end
    end
  end

  sub_test_case "#update" do
    sub_test_case "when passed values are valid" do
      setup do
        @attributes = { foo: "hello" }
        @instance   = create_dinamo(klass: Ghana, **@attributes)
      end

      test "should update values correctly" do
        assert { @instance.update(foo: "hey") == true }
        assert { @instance.foo == "hey" }
        assert { Ghana.get(id: @instance.id, type: @instance.type).foo == "hey" }
      end
    end

    sub_test_case "when passed values are invalid" do
      setup { @instance = create_dinamo(klass: Ghana) }

      test "should not update values" do
        assert { not @instance.update(id: 123) }
        assert { Ghana.get(id: @instance.id, type: @instance.type).id != 123 }
      end
    end
  end

  sub_test_case "#update!" do
    sub_test_case "when passed values are valid" do
      setup do
        @attributes = { foo: "hello" }
        @instance   = create_dinamo(klass: Ghana, **@attributes)
      end

      test "should update values correctly" do
        assert { @instance.update!(foo: "hey") == true }
        assert { @instance.foo == "hey" }
        assert { Ghana.get(id: @instance.id, type: @instance.type).foo == "hey" }
      end
    end

    sub_test_case "when passed values contain primary key" do
      setup { @instance = create_dinamo(klass: Ghana) }

      test "should not update values" do
        assert_raise Dinamo::Exceptions::PrimaryKeyError do
          @instance.update!(id: 123)
        end
      end
    end

    sub_test_case "when passed values contain unsupported field" do
      setup { @instance = create_dinamo(klass: Ghana) }

      test "should not update values" do
        assert_raise Dinamo::Exceptions::ValidationError do
          @instance.update!(ughhhaaaa: 123)
        end
      end
    end
  end

  sub_test_case "#save" do
    sub_test_case "when current attributes are valid" do
      setup { @instance = build_dinamo(klass: Ghana, foo: "1234") }

      test "should save current attributes correctly" do
        assert { @instance.save == true }
      end
    end

    sub_test_case "when current attributes are invalid" do
      setup { @instance = build_dinamo(klass: Ghana, foo: "1234", whooo: true) }

      test "should not save current attributes correctly" do
        assert { not @instance.save }
      end
    end
  end

  sub_test_case "#save!" do
    sub_test_case "when current attributes are valid" do
      setup { @instance = build_dinamo(klass: Ghana, foo: "1234") }

      test "should save current attributes correctly" do
        assert { @instance.save! == true }
      end
    end

    sub_test_case "when current attributes are invalid" do
      setup { @instance = build_dinamo(klass: Ghana, foo: "1234", whooo: true) }

      test "should not save current attributes correctly" do
        assert_raise Dinamo::Exceptions::ValidationError do
          @instance.save! == false
        end
      end
    end
  end

  sub_test_case "#destroy" do
    sub_test_case "when current record is persisted" do
      setup  { @instance = create_dinamo(klass: Ghana, foo: "1234") }
      test "should not destroy myself" do
        assert { @instance.destroy == true }
      end
    end

    sub_test_case "when current record isn't persisted" do
      setup  { @instance = build_dinamo(klass: Ghana, foo: "1234") }
      test "should not destroy myself" do
        assert { not @instance.destroy }
      end
    end
  end

  sub_test_case "#destroyed?" do
    sub_test_case "when current record is destroyed" do
      setup do
        @instance = create_dinamo(klass: Ghana, foo: "1234")
        @instance.destroy
      end

      test "should be truthy" do
        assert { @instance.destroyed? == true }
      end
    end

    sub_test_case "when current record isn't destroyed" do
      setup  { @instance = create_dinamo(klass: Ghana, foo: "1234") }
      test "should be falsey" do
        assert { not @instance.destroyed? }
      end
    end
  end

  sub_test_case "#persisted?" do
    sub_test_case "when current record is persisted" do
      setup { @instance = create_dinamo(klass: Ghana, foo: "1234") }
      test "should be truthy" do
        assert { @instance.persisted? == true }
      end
    end

    sub_test_case "when current record isn't persisted" do
      setup  { @instance = build_dinamo(klass: Ghana, foo: "1234") }
      test "should be falsey" do
        assert { not @instance.persisted? }
      end
    end
  end

  sub_test_case "#new_record?" do
    sub_test_case "when current record is persisted" do
      setup { @instance = create_dinamo(klass: Ghana, foo: "1234") }
      test "should be falsey" do
        assert { not @instance.new_record? }
      end
    end

    sub_test_case "when current record isn't persisted" do
      setup  { @instance = build_dinamo(klass: Ghana, foo: "1234") }
      test "should be falsey" do
        assert { @instance.new_record? == true }
      end
    end
  end

  sub_test_case "#changed?" do
    sub_test_case "when current record is changed" do
      setup do
        @instance = create_dinamo(klass: Ghana, foo: "1234")
        @instance.foo = "changed!"
      end
      test "should be truthy" do
        assert { @instance.changed? }
      end
    end

    sub_test_case "when current record isn't persisted" do
      setup  { @instance = build_dinamo(klass: Ghana, foo: "1234") }
      test "should be falsey" do
        assert { not @instance.changed? }
      end
    end
  end

  sub_test_case "#reload!" do
    sub_test_case "when current record is reloaded" do
      setup do
        @instance = create_dinamo(klass: Ghana, foo: "1234")
        @object_id = @instance.object_id
        Ghana.get(@instance.primary_keys).update(foo: "5678")
        @instance.reload!
      end
      test "should be truthy" do
        assert { @object_id = @instance.object_id }
        assert { @instance.foo == "5678" }
      end
    end
  end
end
