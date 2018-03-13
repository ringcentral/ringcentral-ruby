require 'ringcentral'
require 'subscription'
require 'dotenv'
require 'rspec'

Dotenv.load
$rc = RingCentral.new(ENV['clientId'], ENV['clientSecret'], ENV['server'])
$rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])

def createSubscription(callback)
  events = [
    '/restapi/v1.0/account/~/extension/~/message-store',
  ]
  subscription = PubNub.new($rc, events, lambda { |message|
    callback.call(message)
  })
  subscription.subscribe()
  return subscription
end

RSpec.describe 'Subscription' do
  describe 'subscription' do
    it 'receives message notification' do
      count = 0
      createSubscription(lambda { |message|
        count += 1
      })

      $rc.post('/restapi/v1.0/account/~/extension/~/sms', payload: {
        to: [{phoneNumber: ENV['receiver']}],
        from: {phoneNumber: ENV['username']},
        text: 'Hello world'
      })
      sleep(20)

      expect(count).to be > 0
    end

    it 'refresh' do
      count = 0
      subscription = createSubscription(lambda { |message|
        count += 1
      })

      subscription.refresh()

      $rc.post('/restapi/v1.0/account/~/extension/~/sms', payload: {
        to: [{phoneNumber: ENV['receiver']}],
        from: {phoneNumber: ENV['username']},
        text: 'Hello world'
      })
      sleep(20)

      expect(count).to be > 0
    end

    it 'revoke' do
      count = 0
      subscription = createSubscription(lambda { |message|
        count += 1
      })

      subscription.revoke()

      $rc.post('/restapi/v1.0/account/~/extension/~/sms', payload: {
        to: [{phoneNumber: ENV['receiver']}],
        from: {phoneNumber: ENV['username']},
        text: 'Hello world'
      })
      sleep(20)

      expect(count).to eq(0)
    end
  end
end
