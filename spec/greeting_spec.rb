RSpec.describe 'Greeting' do
  describe 'create custom user greeting' do
    it 'should upload and apply a custom work-hours voicemail greeting' do
      rc = RingCentral.new(ENV['RINGCENTRAL_CLIENT_ID'], ENV['RINGCENTRAL_CLIENT_SECRET'], ENV['RINGCENTRAL_SERVER_URL'])
      rc.authorize(jwt: ENV['RINGCENTRAL_JWT_TOKEN'])

      r = rc.post('/restapi/v1.0/account/~/extension/~/greeting',
        params: { apply: true },
        payload: { type: 'Voicemail', stateId: 'work-hours' },
        files: [
          ['spec/test.wav', 'audio/wav']
        ]
      )
      expect(r).not_to be_nil
      greeting = r.body
      expect(greeting['id']).not_to be_nil
      expect(greeting['type']).to eq('Voicemail')

      rc.revoke()
    end
  end
end
