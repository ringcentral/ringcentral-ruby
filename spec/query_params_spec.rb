require 'dotenv'
require 'ringcentral'

RSpec.describe 'query params' do
  describe 'single' do
    it 'contain single query param' do
      Dotenv.load
      rc = RingCentral.new(ENV['RINGCENTRAL_CLIENT_ID'], ENV['RINGCENTRAL_CLIENT_SECRET'], ENV['RINGCENTRAL_SERVER_URL'])
      rc.authorize(username: ENV['RINGCENTRAL_USERNAME'], extension: ENV['RINGCENTRAL_EXTENSION'], password: ENV['RINGCENTRAL_PASSWORD'])
      r = rc.get('/restapi/v1.0/account/~/extension/~/address-book/contact', { phoneNumber: '666' })
      expect(r).not_to be_nil
      message = r.body
      expect(message['uri']).to include('phoneNumber=666')

      r = rc.get('/restapi/v1.0/account/~/extension/~/address-book/contact', { phoneNumber: ['666', '888'] })
      expect(r).not_to be_nil
      message = r.body
      expect(message['uri']).to include('phoneNumber=666&phoneNumber=888')

      rc.revoke()
    end
  end
end
