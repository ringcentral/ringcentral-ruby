require 'subscription'
require 'rspec'

$rc = RingCentral.new(ENV['RINGCENTRAL_CLIENT_ID'], ENV['RINGCENTRAL_CLIENT_SECRET'], ENV['RINGCENTRAL_SERVER_URL'])

RSpec.describe 'WebSocket Subscription' do
  def createSubscription(callback)
    events = [
      '/restapi/v1.0/account/~/extension/~/message-store?type=Pager',
    ]
    existing_ids = $rc.get('/restapi/v1.0/subscription').body.fetch('records').map { |record| record.fetch('id') }
    subscription = WS.new($rc, events, lambda { |message|
      callback.call(message)
    })
    subscription.subscribe()
    # subscribe starts a thread; wait for server acceptance before sending a pager.
    begin
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 30
      loop do
        records = $rc.get('/restapi/v1.0/subscription').body.fetch('records')
        ready = records.any? do |record|
          !existing_ids.include?(record.fetch('id')) && record['status'] == 'Active' &&
            record.dig('deliveryMode', 'transportType') == 'WebSocket' &&
            record.fetch('eventFilters').any? { |filter| filter.end_with?('/message-store?type=Pager') }
        end
        break if ready
        if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
          raise 'WebSocket Pager subscription did not become active within 30 seconds'
        end
        sleep(1)
      end
    rescue StandardError
      subscription.revoke()
      raise
    end
    # subscription.on_ws_closed = lambda { |event|
    #   puts 'WebSocket closed'
    # }
    return subscription
  end

  describe 'WebSocket Subscription' do
    it 'receives message notification' do
      $rc.authorize(jwt: ENV['RINGCENTRAL_JWT_TOKEN'])
      count = 0
      notifications = Queue.new
      sub = createSubscription(lambda { |message|
        count += 1
        notifications << true
      })

      $rc.post('/restapi/v1.0/account/~/extension/~/company-pager', payload: {
        to: [{extensionId: $rc.token['owner_id']}],
        from: {extensionId: $rc.token['owner_id']},
        text: 'Hello world'
      })
      expect(notifications.pop(timeout: 30)).to eq(true)
      expect(count).to be > 0

      # sleep for some time and see if the websocket is still alive
      sleep(20)
      notifications.clear
      $rc.post('/restapi/v1.0/account/~/extension/~/company-pager', payload: {
        to: [{extensionId: $rc.token['owner_id']}],
        from: {extensionId: $rc.token['owner_id']},
        text: 'Hello world'
      })
      expect(notifications.pop(timeout: 30)).to eq(true)
      expect(count).to be > 1
    ensure
      sub&.revoke()
      $rc.revoke()
    end

    it 'revoke' do
      $rc.authorize(jwt: ENV['RINGCENTRAL_JWT_TOKEN'])
      count = 0
      subscription = createSubscription(lambda { |message|
        count += 1
      })

      subscription.revoke()

      $rc.post('/restapi/v1.0/account/~/extension/~/company-pager', payload: {
        to: [{extensionId: $rc.token['owner_id']}],
        from: {extensionId: $rc.token['owner_id']},
        text: 'Hello world'
      })
      sleep(30)

      expect(count).to eq(0)
    ensure
      subscription&.revoke()
      $rc.revoke()
    end
  end
end
