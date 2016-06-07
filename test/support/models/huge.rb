class Huge < Dinamo::Model
  strict false
  self.table_name = "dinamo_tests2"
  hash_key :id, type: :number
  range_key :type, type: :string
  field :lucky_number, default: 1
end
