require 'ringcentral'
require 'dotenv'
require 'rspec'

RSpec.describe 'Subscription' do
  describe 'subscription' do
    it 'receives message notification' do
      Dotenv.load
      rc = RingCentral.new(ENV['appKey'], ENV['appSecret'], ENV['server'])
      rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])

      events = [
        '/restapi/v1.0/account/~/extension/~/message-store',
      ]
      count = 0
      subscription = rc.subscription(events, lambda { |message|
        count += 1
      })
      subscription.subscribe()

      rc.post('/restapi/v1.0/account/~/extension/~/sms', payload: {
        to: [{phoneNumber: ENV['receiver']}],
        from: {phoneNumber: ENV['username']},
        text: 'Hello world'
      })
      sleep(20)

      expect(count).to be > 0
    end
  end
end
