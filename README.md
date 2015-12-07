# Dinamo

Dinamo is an simple ORM for Amazon DynamoDB for Ruby applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dinamo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dinamo

## Usage

### Sample

Your class must inherit `Dinamo::Model` in every Dinamo model.

```ruby
class User < Dinamo::Model
  hash_key :id, type: :number
  range_key :kind, type: :string
  field :name, type: :string
end

user = User.new
user.id   = 1
user.kind = "developer"
user.name = "namusyaka"

user.valid? #=> true
user.errors #=> {}
user.save #=> true
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/namusyaka/dinamo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

