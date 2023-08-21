require 'ringcentral'

RSpec.describe 'RingCentral' do
  describe 'ringcentral' do
    it 'test_class_variables' do
      expect('https://platform.devtest.ringcentral.com').to eq(RingCentral.SANDBOX_SERVER)
      expect('https://platform.ringcentral.com').to eq(RingCentral.PRODUCTION_SERVER)
    end

    it 'test_initializer' do
      rc = RingCentral.new('client_id', 'client_secret', RingCentral.SANDBOX_SERVER)
      expect('client_id').to eq(rc.client_id)
      expect('client_secret').to eq(rc.client_secret)
      expect('https://platform.devtest.ringcentral.com').to eq(rc.server)
      expect(false).to eq(rc.auto_refresh)
    end

    it 'test_authorize_uri' do
      rc = RingCentral.new('client_id', 'client_secret', RingCentral.SANDBOX_SERVER)
      expect(RingCentral.SANDBOX_SERVER + '/restapi/oauth/authorize?client_id=client_id&redirect_uri=https%3A%2F%2Fexample.com&response_type=code&state=mystate').to eq(rc.authorize_uri('https://example.com', {state: 'mystate'}))
    end

    it 'test_jwt_flow' do
      Dotenv.load
      rc = RingCentral.new(ENV['RINGCENTRAL_CLIENT_ID'], ENV['RINGCENTRAL_CLIENT_SECRET'], ENV['RINGCENTRAL_SERVER_URL'])
      expect(rc.token).to be_nil

      # create token
      rc.authorize(jwt: ENV['RINGCENTRAL_JWT_TOKEN'])
      expect(rc.token).not_to be_nil

      # refresh token
      rc.refresh
      expect(rc.token).not_to be_nil

      # revoke token
      rc.revoke
      expect(rc.token).to be_nil
    end

    it 'test_http_methods' do
      Dotenv.load
      rc = RingCentral.new(ENV['RINGCENTRAL_CLIENT_ID'], ENV['RINGCENTRAL_CLIENT_SECRET'], ENV['RINGCENTRAL_SERVER_URL'])
      rc.authorize(jwt: ENV['RINGCENTRAL_JWT_TOKEN'])

      # get
      r = rc.get('/restapi/v1.0/account/~/extension/~')
      expect(r).not_to be_nil
      expect('101').to eq(r.body['extensionNumber'])

      # post
      r = rc.post('/restapi/v1.0/account/~/extension/~/sms', payload: {
        to: [{phoneNumber: ENV['RINGCENTRAL_RECEIVER']}],
        from: {phoneNumber: ENV['RINGCENTRAL_SENDER']},
        text: 'Hello world'
      })
      expect(r).not_to be_nil
      message = r.body
      expect('SMS').to eq(message['type'])
      messageUrl = "/restapi/v1.0/account/~/extension/~/message-store/#{message['id']}"

      # put
      r = rc.put(messageUrl, payload: { readStatus: 'Unread' })
      expect(r).not_to be_nil
      message = r.body
      expect('Unread').to eq(message['readStatus'])
      r = rc.put(messageUrl, payload: { readStatus: 'Read' })
      expect(r).not_to be_nil
      message = r.body
      expect('Read').to eq(message['readStatus'])

      # todo: test patch

      # delete
      # todo: delete "availability" is broken, because of sandbox env
      # r = rc.delete(messageUrl)
      # expect(r).not_to be_nil
      # r = rc.get(messageUrl)
      # expect(r).not_to be_nil
      # message = r.body
      # expect('Deleted').to eq(message['availability'])

      rc.revoke()
    end
  end
end
