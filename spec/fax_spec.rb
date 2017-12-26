require 'dotenv'
require 'ringcentral'

RSpec.describe 'Fax' do
  describe 'send fax' do
    Dotenv.load
    rc = RingCentral.new(ENV['appKey'], ENV['appSecret'], ENV['server'])
    rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])
    # todo: send fax
    rc.upload
  end
end
