module Dinamo
  module Exceptions
    CastError             = Class.new(ArgumentError)
    PrimaryKeyError       = Class.new(ArgumentError)
    ValidationError       = Class.new(ArgumentError)
    RecordNotFoundError   = Class.new(ArgumentError)
    UnsupportedTypeError  = Class.new(ArgumentError)
    ResourceNotFoundError = Class.new(StandardError)
  end
end
