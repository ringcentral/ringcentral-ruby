require 'concurrent'
require 'openssl'
require 'base64'
require 'faye/websocket'
require 'securerandom'
require 'eventmachine'

class WS
  def initialize(ringcentral, events, callback)
    @rc = ringcentral
    @events = events
    @callback = callback
  end

  def subscribe
    r = @rc.post('/restapi/oauth/wstoken').body
    @t = Thread.new do
      EM.run {
        @ws = Faye::WebSocket::Client.new(r['uri'] + '?access_token=' + r['ws_access_token'])
        @ws.on :open do
          @ws.send([
            { type: 'ClientRequest', method: 'POST', path: '/restapi/v1.0/subscription', messageId: SecureRandom.uuid },
            { deliveryMode: { transportType: 'WebSocket' }, eventFilters: @events }
          ].to_json())
        end
        @ws.on :message do |event|
          header, body = JSON.parse(event.data)
          if header['type'] == 'ServerNotification'
            @callback.call(body)
          end
        end
      }
    end
  end

  def revoke
    @t.kill
  end
end
