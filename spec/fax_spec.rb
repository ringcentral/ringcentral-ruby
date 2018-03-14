require 'dotenv'
require 'ringcentral'

RSpec.describe 'Fax' do
  describe 'send fax' do
    it 'should send a fax' do
      Dotenv.load
      rc = RingCentral.new(ENV['clientId'], ENV['clientSecret'], ENV['server'])
      rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])
      r = rc.post('/restapi/v1.0/account/~/extension/~/fax',
        payload: { to: [{ phoneNumber: ENV['receiver'] }] },
        files: [
          ['spec/request.json', 'application/json'],
          ['spec/test.txt', 'text/plain'],
          ['spec/test.png', 'image/png']
        ]
      )
      expect(r).not_to be_nil
      message = JSON.parse(r.body)
      puts message
      expect('Fax').to eq(message['type'])
    end
  end
end
