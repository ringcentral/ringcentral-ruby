# ringcentral-ruby

[![Build Status](https://travis-ci.org/ringcentral/ringcentral-ruby.svg?branch=master)](https://travis-ci.org/ringcentral/ringcentral-ruby)
[![Coverage Status](https://coveralls.io/repos/github/ringcentral/ringcentral-ruby/badge.svg?branch=master)](https://coveralls.io/github/ringcentral/ringcentral-ruby?branch=master)

Ruby SDK for RingCentral.


## Installation

```
gem install ringcentral-sdk
```


## Documentation

https://developer.ringcentral.com/api-docs/latest/index.html


## Usage

```ruby
require 'ringcentral'

rc = RingCentral.new(ENV['clientId'], ENV['clientSecret'], ENV['server'])
rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])

# get
r = rc.get('/restapi/v1.0/account/~/extension/~')
expect(r).not_to be_nil
expect('101').to eq(JSON.parse(r.body)['extensionNumber'])
```


### Token Refresh

Access token expires. You need to call `rc.refresh()` before it expores.
If you want the SDK to do auto refresh please `rc.auto_refresh = true` before authorization.


### Send SMS

```ruby
r = rc.post('/restapi/v1.0/account/~/extension/~/sms', payload: {
    to: [{phoneNumber: ENV['receiver']}],
    from: {phoneNumber: ENV['username']},
    text: 'Hello world'
})
```


### Send fax

```ruby
rc.post('/restapi/v1.0/account/~/extension/~/fax',
payload: { to: [{ phoneNumber: ENV['receiver'] }] },
    files: [
        ['spec/test.txt', 'text/plain'],
        ['spec/test.png', 'image/png']
    ]
)
```


### Send MMS

```ruby
r = rc.post('/restapi/v1.0/account/~/extension/~/sms',
    payload: {
        to: [{ phoneNumber: ENV['receiver'] }],
        from: { phoneNumber: ENV['username'] },
        text: 'hello world'
    },
    files: [
        ['spec/test.png', 'image/png']
    ]
)
```


### PubNub subscription

```ruby
def createSubscription(callback)
    events = [
        '/restapi/v1.0/account/~/extension/~/message-store',
    ]
    subscription = PubNub.new(rc, events, lambda { |message|
        callback.call(message)
    })
    subscription.subscribe()
    return subscription
end

createSubscription(lambda { |message|
    puts message
})
```


For more sample code, please refer to the [test cases](/spec).


## How to test

Create `.env` file with the following content:

```
production=false
server=https://platform.devtest.ringcentral.com
clientId=clientId
clientSecret=clientSecret
username=username
extension=extension
password=password
receiver=number-to-receiver-sms
```

Run `rspec`


## License

MIT


## Todo

- Batch requests
