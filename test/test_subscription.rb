require 'test/unit'
require 'ringcentral'
require 'dotenv'

class SubscriptionTest < Test::Unit::TestCase
  def test_create_subscription
    # Dotenv.load
    # rc = RingCentral.new(ENV['appKey'], ENV['appSecret'], ENV['server'])
    # rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])
    # events = [
    #   '/restapi/v1.0/account/~/extension/~/message-store',
    # ]
    # subscription = rc.subscription(events, ->(message) {
    #   puts message
    # })
    # subscription.subscribe()
  end
end
