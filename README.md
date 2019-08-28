# RingCentral SDK for Ruby

[![Build Status](https://travis-ci.org/ringcentral/ringcentral-ruby.svg?branch=master)](https://travis-ci.org/ringcentral/ringcentral-ruby)
[![Coverage Status](https://coveralls.io/repos/github/ringcentral/ringcentral-ruby/badge.svg?branch=master)](https://coveralls.io/github/ringcentral/ringcentral-ruby?branch=master)
[![Community](https://img.shields.io/badge/dynamic/json.svg?label=community&colorB=&suffix=%20users&query=$.approximate_people_count&uri=http%3A%2F%2Fapi.getsatisfaction.com%2Fcompanies%2F102909.json)](https://devcommunity.ringcentral.com/ringcentraldev)
[![Twitter](https://img.shields.io/twitter/follow/ringcentraldevs.svg?style=social&label=follow)](https://twitter.com/RingCentralDevs)

__[RingCentral Developers](https://developer.ringcentral.com/api-products)__ is a cloud communications platform which can be accessed via more than 70 APIs. The platform's main capabilities include technologies that enable:
__[Voice](https://developer.ringcentral.com/api-products/voice), [SMS/MMS](https://developer.ringcentral.com/api-products/sms), [Fax](https://developer.ringcentral.com/api-products/fax), [Glip Team Messaging](https://developer.ringcentral.com/api-products/team-messaging), [Data and Configurations](https://developer.ringcentral.com/api-products/configuration)__.

[API Reference](https://developer.ringcentral.com/api-docs/latest/index.html) and [APIs Explorer](https://developer.ringcentral.com/api-explorer/latest/index.html).

## Installation

```
gem install ringcentral-sdk
```


### Name collision with `ringcentral` gem

The ringcentral gem is using RingCentral's legacy API, everyone is recommended to move to the REST API.

If you have both the ringcentral and ringcentral-sdk gems installed, you will run into a collision error when attempting to initialize the ringcentral-sdk RingCentral SDK.

Solution is `gem uninstall ringcentral`


## Documentation

https://developer.ringcentral.com/api-docs/latest/index.html


## Usage

```ruby
require 'ringcentral'

rc = RingCentral.new('clientID', 'clientSecret', 'serverURL')
rc.authorize(username: 'username', extension: 'extension', password: 'password')

# get
r = rc.get('/restapi/v1.0/account/~/extension/~')
expect(r).not_to be_nil
expect('101').to eq(r.body['extensionNumber'])
```


## How to specify query parameters

### for get & delete

```ruby
rc.get('/restapi/v1.0/account/~/extension', { hello: 'world' })
```

### for post, put & patch

```ruby
rc.post('/restapi/v1.0/account/~/extension/~/sms', payload: body, params: { hello: 'world' })
```

### multi-value query parameter

```ruby
rc.get('/restapi/v1.0/account/~/extension', { hello: ['world1', 'world2'] })
```

Above will be translated to `/restapi/v1.0/account/~/extension?hello=world1&hello=world2`.


### Token Refresh

Access token expires. You need to call `rc.refresh()` before it expires.
If you want the SDK to do auto refresh please `rc.auto_refresh = true` before authorization.


### Load preexisting token

Let's say you already have a token. Then you can load it like this: `rc.token = your_token_object`.

The benifits of loading a preexisting token is you don't need to go through any authorization flow.

If what you have is a JSON string instead of a Ruby object, you need to convert it first: `JSON.parse(your_token_string)`.

If you only have a string for the access token instead of for the whole object, you can set it like this:

```ruby
rc.token = { access_token: 'the token string' }
```


### Send SMS

```ruby
r = rc.post('/restapi/v1.0/account/~/extension/~/sms', payload: {
    to: [{phoneNumber: ENV['RINGCENTRAL_RECEIVER']}],
    from: {phoneNumber: ENV['RINGCENTRAL_USERNAME']},
    text: 'Hello world'
})
```


### Send fax

```ruby
rc.post('/restapi/v1.0/account/~/extension/~/fax',
payload: { to: [{ phoneNumber: ENV['RINGCENTRAL_RECEIVER'] }] },
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
        to: [{ phoneNumber: ENV['RINGCENTRAL_RECEIVER'] }],
        from: { phoneNumber: ENV['RINGCENTRAL_USERNAME'] },
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

```
bundle install --path vendor/bundle
```

Create `.env` file with the following content:

```
RINGCENTRAL_SERVER_URL=https://platform.devtest.ringcentral.com
RINGCENTRAL_CLIENT_ID=
RINGCENTRAL_CLIENT_SECRET=
RINGCENTRAL_USERNAME=
RINGCENTRAL_EXTENSION=
RINGCENTRAL_PASSWORD=
RINGCENTRAL_RECEIVER=
```

`RINGCENTRAL_RECEIVER` is a phone number to receive SMS, Fax..etc.

Run `bundle exec rspec`


## License

MIT


## Todo

- Batch requests
