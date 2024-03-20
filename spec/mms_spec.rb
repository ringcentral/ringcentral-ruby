require 'dotenv'
require 'ringcentral'

RSpec.describe 'MMS' do
  describe 'send MMS' do
    it 'should send an MMS' do
      Dotenv.load
      rc = RingCentral.new(ENV['RINGCENTRAL_CLIENT_ID'], ENV['RINGCENTRAL_CLIENT_SECRET'], ENV['RINGCENTRAL_SERVER_URL'])
      rc.authorize(jwt: ENV['RINGCENTRAL_JWT_TOKEN'])

      r = rc.post('/restapi/v1.0/account/~/extension/~/sms',
        payload: {
          to: [{ phoneNumber: ENV['RINGCENTRAL_RECEIVER'] }],
          from: { phoneNumber: ENV['RINGCENTRAL_SENDER'] },
          text: 'hello world'
        },
        files: [
          ['spec/test.png', 'image/png']
        ]
      )
      expect(r).not_to be_nil
      message = r.body
      expect('SMS').to eq(message['type'])

      rc.revoke()
    end
  end
end
