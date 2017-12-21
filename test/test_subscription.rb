require "minitest/autorun"
require 'ringcentral'
require 'dotenv'

class SubscriptionTest < Minitest::Test
  def test_create_subscription
    Dotenv.load
    rc = RingCentral.new(ENV['appKey'], ENV['appSecret'], ENV['server'])
    rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])
    events = [
      '/restapi/v1.0/account/~/extension/~/message-store',
    ]
    subscription = rc.subscription(events, lambda { |message|
      puts message
    })
    subscription.subscribe()
  end
end
