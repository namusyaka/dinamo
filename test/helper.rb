$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../', __FILE__)
require 'dinamo'
require 'test-unit'
require 'test/unit/rr'
require 'test/unit/power_assert'

Aws.config.update(
  region: 'us-west-2',
  access_key_id: 'howl',
  secret_access_key: 'foo',
)

require 'support/classes'

class Dinamo::Adapter
  def initialize(table_name: nil, **options)
    @options    = options
    @database   = Aws::DynamoDB::Client.new(region: "ap-northeast-1", endpoint: "http://localhost:8000")
    @table_name = table_name
  end
end
