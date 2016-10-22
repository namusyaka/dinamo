# Dinamo

[![build status](https://img.shields.io/travis/namusyaka/dinamo.svg?style=flat-square)](http://travis-ci.org/namusyaka/dinamo)
[![gem](https://img.shields.io/gem/v/dinamo.svg?style=flat-square)](https://rubygems.org/gems/dinamo)
[![license](https://img.shields.io/github/license/namusyaka/dinamo.svg?style=flat-square)](https://github.com/namusyaka/dinamo/blob/master/LICENSE.txt)

Dinamo is an ORM for [Dynamo DB](https://aws.amazon.com/dynamodb/), it has followed the behavior of the ORM which is often seen in the Ruby culture.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dinamo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dinamo

## Overview

Dinamo makes it easy to create DynamoDB record from any ruby object. Also, dinamo supports for [data types of Dynamo DB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.NamingRulesDataTypes.html) such as scaler types, document types and set types. This means things that you can declare their types on your model.

Of course, you can use validations, casting and model change tracking smoothly.
Next section will describe their things with example code.

## Usage

### Model definition

```ruby
class User < Dinamo::Model
  hash_key :name, type: :string
  field    :age,  type: :number
end
```

### Building/Saving

```ruby
user = User.new(name: 'numb', age: 24)
user.persisted? #=> false
user.save
user.persisted? #=> true
```

Or you can use `create`.

```ruby
user = User.create(name: 'numb', age: 24)
user.persisted? #=> true
```

### Dirty (model change tracking)

```ruby
user = User.new(name: 'numb', age: 24)
user.changed? #=> false
user.age = 25
user.changed? #=> true
user.save
user.changed? #=> false
```

### Validation

```ruby
class NameLengthValidator < Dinamo::Model::Validation::Validator
  def validate(record)
    unless options[:length].include?(record.name.length)
      record.errors.add(:name, I18n.t("models.user.error.length"))
    end
  end
end

class User < Dinamo::Model
  hash_key :id
  field :name, type: :string

  validates_with NameLengthValidator, length: 1..30
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/namusyaka/dinamo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

