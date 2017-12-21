require 'pubnub'
require 'concurrent'

class Subscription
  attr_accessor :events

  def initialize(ringcentral, events, message_callback, status_callback = nil, presence_callback = nil)
    @rc = ringcentral
    @events = events
    @callback = Pubnub::SubscribeCallback.new(
      message: lambda { |envelope|
        # todo: decrypt the message
        message_callback.call(envelope)
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
      @timer = Concurrent::TimerTask.new(execution_interval: value['expiresIn'] - 120, timeout_interval: 60) do
        self.refresh
      end
      @timer.execute
    end
  end

  def subscribe
    r = @rc.post('/restapi/v1.0/subscription', payload: request_body)
    self.subscription = JSON.parse(r.body)
    @pubnub = Pubnub.new(subscribe_key: @subscription['deliveryMode']['subscriberKey'])
    @pubnub.add_listener(callback: @callback)
    @pubnub.subscribe(channels: @subscription['deliveryMode']['address'])
  end

  def refresh
    return if @subscription == nil
    r = @rc.put("/restapi/v1.0/subscription/#{@subscription['id']}", payload: request_body)
    self.subscription = JSON.parse(r.body)
  end

  def revoke
    return if @subscription == nil
    @pubnub.unsubscribe(channel: @subscription['deliveryMode']['address'])
    @pubnub.remove_listener(@callback)
    @pubnub = nil
    rc.delete("/restapi/v1.0/subscription/#{@subscription['id']}")
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
