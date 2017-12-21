require "minitest/autorun"
require 'ringcentral'
require 'dotenv'

class SubscriptionTest < Minitest::Test
  def setup
    Dotenv.load
    @rc = RingCentral.new(ENV['appKey'], ENV['appSecret'], ENV['server'])
    @rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])
  end

  def test_create_subscription
    events = [
      '/restapi/v1.0/account/~/extension/~/message-store',
    ]
    count = 0
    subscription = @rc.subscription(events, lambda { |message|
      count += 1
    })
    subscription.subscribe()
    sleep(15)
    assert_operator count, :>, 0
  end
end
