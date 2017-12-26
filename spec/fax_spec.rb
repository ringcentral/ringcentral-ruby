require 'dotenv'
require 'ringcentral'

RSpec.describe 'Fax' do
  describe 'send fax' do
    it 'should send a fax' do
      Dotenv.load
      rc = RingCentral.new(ENV['appKey'], ENV['appSecret'], ENV['server'])
      rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])

      r = rc.upload
      expect(r).not_to be_nil
      message = JSON.parse(r.body)
      expect('Fax').to eq(message['type'])
      puts r.body
    end
  end
end
