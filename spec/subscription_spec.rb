require 'ringcentral'
require 'subscription'
require 'dotenv'
require 'rspec'

Dotenv.load
$rc = RingCentral.new(ENV['RINGCENTRAL_CLIENT_ID'], ENV['RINGCENTRAL_CLIENT_SECRET'], ENV['RINGCENTRAL_SERVER_URL'])
$rc.authorize(jwt: ENV['RINGCENTRAL_JWT_TOKEN'])

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
        to: [{phoneNumber: ENV['RINGCENTRAL_RECEIVER']}],
        from: {phoneNumber: ENV['RINGCENTRAL_SENDER']},
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
        to: [{phoneNumber: ENV['RINGCENTRAL_RECEIVER']}],
        from: {phoneNumber: ENV['RINGCENTRAL_SENDER']},
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
        to: [{phoneNumber: ENV['RINGCENTRAL_RECEIVER']}],
        from: {phoneNumber: ENV['RINGCENTRAL_SENDER']},
        text: 'Hello world'
      })
      sleep(20)

      expect(count).to eq(0)
    end
  end
end
