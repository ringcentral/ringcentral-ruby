require 'dotenv'
require 'ringcentral'

RSpec.describe 'MMS' do
  describe 'send MMS' do
    it 'should send an MMS' do
      Dotenv.load
      rc = RingCentral.new(ENV['clientId'], ENV['clientSecret'], ENV['server'])
      rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])

      r = rc.post('/restapi/v1.0/account/~/extension/~/sms',
        payload: {
          to: [{ phoneNumber: ENV['receiver'] }],
          from: { phoneNumber: ENV['username'] },
          text: 'hello world'
        },
        files: [
          'spec/test.png;type=image/png'
        ]
      )
      expect(r).not_to be_nil
      message = JSON.parse(r.body)
      expect('SMS').to eq(message['type'])
    end
  end
end
