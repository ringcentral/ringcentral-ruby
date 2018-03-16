require 'ringcentral'

RSpec.describe 'RingCentral' do
  describe 'ringcentral' do
    it 'test_class_variables' do
      expect('https://platform.devtest.ringcentral.com').to eq(RingCentral.SANDBOX_SERVER)
      expect('https://platform.ringcentral.com').to eq(RingCentral.PRODUCTION_SERVER)
    end

    it 'test_initializer' do
      rc = RingCentral.new('app_key', 'app_secret', RingCentral.SANDBOX_SERVER)
      expect('app_key').to eq(rc.app_key)
      expect('app_secret').to eq(rc.app_secret)
      expect('https://platform.devtest.ringcentral.com').to eq(rc.server)
      expect(false).to eq(rc.auto_refresh)
    end

    it 'test_authorize_uri' do
      rc = RingCentral.new('app_key', 'app_secret', RingCentral.SANDBOX_SERVER)
      expect(RingCentral.SANDBOX_SERVER + '/restapi/oauth/authorize?client_id=app_key&redirect_uri=https%3A%2F%2Fexample.com&response_type=code&state=mystate').to eq(rc.authorize_uri('https://example.com', 'mystate'))
    end

    it 'test_password_flow' do
      Dotenv.load
      rc = RingCentral.new(ENV['clientId'], ENV['clientSecret'], ENV['server'])
      expect(rc.token).to be_nil

      # create token
      rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])
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
      rc = RingCentral.new(ENV['clientId'], ENV['clientSecret'], ENV['server'])
      rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])

      # get
      r = rc.get('/restapi/v1.0/account/~/extension/~')
      expect(r).not_to be_nil
      expect('101').to eq(JSON.parse(r.body)['extensionNumber'])

      # post
      r = rc.post('/restapi/v1.0/account/~/extension/~/sms', payload: {
        to: [{phoneNumber: ENV['receiver']}],
        from: {phoneNumber: ENV['username']},
        text: 'Hello world'
      })
      expect(r).not_to be_nil
      message = JSON.parse(r.body)
      expect('SMS').to eq(message['type'])
      messageUrl = "/restapi/v1.0/account/~/extension/~/message-store/#{message['id']}"

      # put
      r = rc.put(messageUrl, payload: { readStatus: 'Unread' })
      expect(r).not_to be_nil
      message = JSON.parse(r.body)
      expect('Unread').to eq(message['readStatus'])
      r = rc.put(messageUrl, payload: { readStatus: 'Read' })
      expect(r).not_to be_nil
      message = JSON.parse(r.body)
      expect('Read').to eq(message['readStatus'])

      # todo: test patch

      # delete
      r = rc.delete(messageUrl)
      expect(r).not_to be_nil
      r = rc.get(messageUrl)
      expect(r).not_to be_nil
      message = JSON.parse(r.body)
      expect('Deleted').to eq(message['availability'])
    end
  end
end
