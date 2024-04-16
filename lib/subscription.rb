require 'concurrent'
require 'faye/websocket'
require 'securerandom'
require 'eventmachine'

class WS
  def initialize(ringcentral, events, callback, debugMode = false)
    @rc = ringcentral
    @events = events
    @callback = callback
    @debugMode = debugMode
  end

  def on_ws_closed=(callback)
    @on_ws_closed = callback
  end

  def subscribe
    r = @rc.post('/restapi/oauth/wstoken').body
    @t = Thread.new do
      EM.run {
        @ws = Faye::WebSocket::Client.new(r['uri'] + '?access_token=' + r['ws_access_token'])
        if @debugMode
          class << @ws
            def send(message)
              puts "Sending...\n" + message
              super(message)
            end
          end
        end
        @ws.on :open do
          @ws.send([
            { type: 'ClientRequest', method: 'POST', path: '/restapi/v1.0/subscription', messageId: SecureRandom.uuid },
            { deliveryMode: { transportType: 'WebSocket' }, eventFilters: @events }
          ].to_json())

          # send a heartbeat every 10 minutes
          @task = Concurrent::TimerTask.new(execution_interval: 600) do
            @ws.send([
              { type: 'Heartbeat', messageId: SecureRandom.uuid },
            ].to_json())
          end
          @task.execute
        end
        @ws.on :message do |event|
          if @debugMode
            puts "Receiving...\n" + event.data
          end
          header, body = JSON.parse(event.data)
          if header['type'] == 'ServerNotification'
            @callback.call(body)
          end
        end
        @ws.on :close do |event|
          if @on_ws_closed
            @on_ws_closed.call(event)
          end
        end
      }
    end
  end

  def revoke
    @t.kill
  end
end
