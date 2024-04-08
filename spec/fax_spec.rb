require 'dotenv'
require 'ringcentral'

RSpec.describe 'Fax' do
  describe 'send fax' do
    it 'should send a fax' do
      Dotenv.load
      rc = RingCentral.new(ENV['RINGCENTRAL_CLIENT_ID'], ENV['RINGCENTRAL_CLIENT_SECRET'], ENV['RINGCENTRAL_SERVER_URL'])
      puts "RINGCENTRAL_CLIENT_ID: #{ENV['RINGCENTRAL_CLIENT_ID']}"
      puts "RINGCENTRAL_CLIENT_SECRET: #{ENV['RINGCENTRAL_CLIENT_SECRET']}"
      puts "RINGCENTRAL_SERVER_URL: #{ENV['RINGCENTRAL_SERVER_URL']}"
      rc.authorize(jwt: ENV['RINGCENTRAL_JWT_TOKEN'])
      r = rc.post('/restapi/v1.0/account/~/extension/~/fax',
        payload: { to: [{ phoneNumber: ENV['RINGCENTRAL_RECEIVER'] }] },
        files: [
          ['spec/test.txt', 'text/plain'],
          ['spec/test.png', 'image/png']
        ]
      )
      expect(r).not_to be_nil
      message = r.body
      expect('Fax').to eq(message['type'])

      rc.revoke()
    end
  end
end
