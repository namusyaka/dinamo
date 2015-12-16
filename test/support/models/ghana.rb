class Ghana < Dinamo::Model
  self.table_name = "dinamo_tests"
  hash_key :id, type: :number
  range_key :type, type: :string
  field :pocky, type: :string
  field :foo
  field :bar
end
