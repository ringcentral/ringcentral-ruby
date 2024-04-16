require 'ringcentral'
require 'subscription'
require 'dotenv'
require 'rspec'
require "simplecov"
SimpleCov.start

Dotenv.load
$rc = RingCentral.new(ENV['RINGCENTRAL_CLIENT_ID'], ENV['RINGCENTRAL_CLIENT_SECRET'], ENV['RINGCENTRAL_SERVER_URL'])

RSpec.describe 'WebSocket Subscription' do
  def createSubscription(callback)
    events = [
      '/restapi/v1.0/account/~/extension/~/message-store?type=Pager',
    ]
    subscription = WS.new($rc, events, lambda { |message|
      callback.call(message)
    })
    subscription.subscribe()
    # subscription.on_ws_closed = lambda { |event|
    #   puts 'WebSocket closed'
    # }
    return subscription
  end

  describe 'WebSocket Subscription' do
    it 'receives message notification' do
      $rc.authorize(jwt: ENV['RINGCENTRAL_JWT_TOKEN'])
      count = 0
      sub = createSubscription(lambda { |message|
        count += 1
      })

      $rc.post('/restapi/v1.0/account/~/extension/~/company-pager', payload: {
        to: [{extensionId: $rc.token['owner_id']}],
        from: {extensionId: $rc.token['owner_id']},
        text: 'Hello world'
      })
      sleep(10)
      expect(count).to be > 0

      # sleep for some time and see if the websocket is still alive
      sleep(20)
      $rc.post('/restapi/v1.0/account/~/extension/~/company-pager', payload: {
        to: [{extensionId: $rc.token['owner_id']}],
        from: {extensionId: $rc.token['owner_id']},
        text: 'Hello world'
      })
      sleep(10)
      expect(count).to be > 1

      sub.revoke()
      $rc.revoke()
    end

    it 'revoke' do
      $rc.authorize(jwt: ENV['RINGCENTRAL_JWT_TOKEN'])
      count = 0
      subscription = createSubscription(lambda { |message|
        count += 1
      })

      subscription.revoke()

      $rc.post('/restapi/v1.0/account/~/extension/~/company-pager', payload: {
        to: [{extensionId: $rc.token['owner_id']}],
        from: {extensionId: $rc.token['owner_id']},
        text: 'Hello world'
      })
      sleep(10)

      expect(count).to eq(0)
      $rc.revoke()
    end
  end
end
