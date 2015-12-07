require 'support/dinamo/ext'
require 'support/dinamo/helpers'
require 'support/dinamo/database'

class BaseTestCase < Test::Unit::TestCase
  include Dinamo::Test::Ext
  include Dinamo::Test::Helpers
end
