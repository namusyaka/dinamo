class Ghana < Dinamo::Model
  hash_key :id, type: :number
  range_key :type, type: :string
  field :pocky, type: :string
  field :foo
  field :bar
end
