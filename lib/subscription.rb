require 'pubnub'
require 'concurrent'
require 'openssl'
require 'base64'
require 'faye/websocket'
require 'securerandom'

class WS
  def initialize(ringcentral, events, callback)
    @rc = ringcentral
    @events = events
    @callback = callback
  end

  def subscribe
    r = @rc.post('/restapi/oauth/wstoken').body
    @ws = Faye::WebSocket::Client.new(r.uri + '?access_token=' + r.ws_access_token)
    @ws.on :open do
      @ws.send([
        { type: 'ClientRequest', method: 'POST', path: '/restapi/v1.0/subscription', messageId: SecureRandom.uuid },
        { deliveryMode: { transportType: 'WebSocket' }, eventFilters: @events }
      ].to_json())
    end
    @ws.on :message do |event|
      header, body = JSON.parse(event.data)
      if heander['messageType'] == 'ServerNotification'
        @callback.call(body)
      end
    end
  end

  def revoke
    @ws.close
  end
end

class PubNub
  attr_accessor :events

  def initialize(ringcentral, events, message_callback, status_callback = nil, presence_callback = nil)
    @rc = ringcentral
    @events = events
    @callback = Pubnub::SubscribeCallback.new(
      message: lambda { |envelope|
        message = envelope.result[:data][:message]
        cipher = OpenSSL::Cipher::AES.new(128, :ECB)
        cipher.decrypt
        cipher.key = Base64.decode64(@subscription['deliveryMode']['encryptionKey'])
        ciphertext = Base64.decode64(message)
        plaintext = cipher.update(ciphertext) + cipher.final
        message_callback.call(JSON.parse(plaintext))
      },
      presence: lambda { |envelope|
        presence_callback != nil && presence_callback.call(envelope)
      },
      status: lambda { |envelope|
        status_callback != nil && status_callback.call(envelope)
      }
    )
    @subscription = nil
    @timer = nil
    @pubnub = nil
  end

  def subscription=(value)
    @subscription = value
    if @timer != nil
      @timer.shutdown
      @timer = nil
    end
    if value != nil
      @timer = Concurrent::TimerTask.new(execution_interval: value['expiresIn'] - 120) do
        self.refresh
      end
      @timer.execute
    end
  end

  def subscribe
    r = @rc.post('/restapi/v1.0/subscription', payload: request_body)
    self.subscription = r.body
    @pubnub = Pubnub.new(subscribe_key: @subscription['deliveryMode']['subscriberKey'], user_id: @rc.token['owner_id'])
    @pubnub.add_listener(name: 'default', callback: @callback)
    @pubnub.subscribe(channels: @subscription['deliveryMode']['address'])
  end

  def refresh
    return if @subscription == nil
    r = @rc.put("/restapi/v1.0/subscription/#{@subscription['id']}", payload: request_body)
    self.subscription = r.body
  end

  def revoke
    return if @subscription == nil
    @pubnub.unsubscribe(channel: @subscription['deliveryMode']['address'])
    @pubnub.remove_listener(name: 'default')
    @pubnub = nil
    @rc.delete("/restapi/v1.0/subscription/#{@subscription['id']}")
    self.subscription = nil
  end

  private

    def request_body
      {
        'deliveryMode': { 'transportType': 'PubNub', 'encryption': true },
        'eventFilters': @events
      }
    end
end
