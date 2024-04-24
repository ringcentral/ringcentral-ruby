# RingCentral SDK for Ruby

[![Ruby](https://github.com/ringcentral/ringcentral-ruby/actions/workflows/ruby.yml/badge.svg)](https://github.com/ringcentral/ringcentral-ruby/actions/workflows/ruby.yml)
[![Reference](https://img.shields.io/badge/rubydoc-reference-blue?logo=ruby)](https://ringcentral.github.io/ringcentral-ruby/)
[![Twitter](https://img.shields.io/twitter/follow/ringcentraldevs.svg?style=social&label=follow)](https://twitter.com/RingCentralDevs)

__[RingCentral Developers](https://developer.ringcentral.com/api-products)__ is a cloud communications platform which can be accessed via more than 70 APIs. The platform's main capabilities include technologies that enable:
__[Voice](https://developer.ringcentral.com/api-products/voice), [SMS/MMS](https://developer.ringcentral.com/api-products/sms), [Fax](https://developer.ringcentral.com/api-products/fax), [Glip Team Messaging](https://developer.ringcentral.com/api-products/team-messaging), [Data and Configurations](https://developer.ringcentral.com/api-products/configuration)__.

## Additional resources

* [RingCentral API Reference](https://developer.ringcentral.com/api-docs/latest/index.html) - an interactive reference for the RingCentral API that allows developers to make API calls with no code.
* [Document](https://ringcentral.github.io/ringcentral-ruby/) - an interactive reference for the SDK code documentation.


## Getting help and support

If you are having difficulty using this SDK, or working with the RingCentral API, please visit our [developer community forums](https://community.ringcentral.com/spaces/144/) for help and to get quick answers to your questions. If you wish to contact the RingCentral Developer Support team directly, please [submit a help ticket](https://developers.ringcentral.com/support/create-case) from our developer website.


## Installation

```
gem install ringcentral-sdk
```

If for some reason `eventmachine` failed to install, please check [this](https://stackoverflow.com/a/31516586/862862).


### Name collision with `ringcentral` gem

The `ringcentral` gem is using RingCentral's legacy API which was End-of-Lifed in 2018. Everyone is recommended to move to the REST API.

If you have both the `ringcentral` and `ringcentral-sdk` gems installed, you will run into a collision error when attempting to initialize the `ringcentral-sdk` RingCentral SDK.

The solution is `gem uninstall ringcentral`


## Documentation

https://developer.ringcentral.com/api-docs/latest/index.html


## Usage

```ruby
require 'ringcentral'

rc = RingCentral.new('clientID', 'clientSecret', 'serverURL')
rc.authorize(jwt: 'jwt-token')

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


### Load pre-existing token

Let's say you already have a token. Then you can load it like this: `rc.token = your_token_object`.
The benefit of loading a preexisting token is you don't need to go through any authorization flow.

If what you have is a JSON string instead of a Ruby object, you need to convert it first: `JSON.parse(your_token_string)`.

If you only have a string for the access token instead of for the whole object, you can set it like this:

```ruby
rc.token = { access_token: 'the token string' }
```


### Send SMS

```ruby
r = rc.post('/restapi/v1.0/account/~/extension/~/sms', payload: {
    to: [{phoneNumber: ENV['RINGCENTRAL_RECEIVER']}],
    from: {phoneNumber: ENV['RINGCENTRAL_SENDER']},
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
        from: { phoneNumber: ENV['RINGCENTRAL_SENDER'] },
        text: 'hello world'
    },
    files: [
        ['spec/test.png', 'image/png']
    ]
)
```


## Subscriptions

### WebSocket Subscriptions

```ruby
events = [
  '/restapi/v1.0/account/~/extension/~/message-store',
]
subscription = WS.new(rc, events, lambda { |message|
  puts message
})
subscription.subscribe()
```

#### How to keep a subscription running 24 * 7?

There are two main cases that a subscription will be terminated:

- Absolute time out. The maximum time for a subscription to run is 24 hours. After that, the websocket connection will be closed by the server.
- Network issue. It could be your local network issue or the server's network issue. In either case, your websocket connection will be closed

In order to keep a subscription running 24 * 7, you need to re-subscribe when the connection is closed.

```ruby
subscription.on_ws_closed = lambda { |event|
  # make sure that there is no network issue and re-subscribe
  subscription.subscribe()
}
```


## How to test

```
bundle install
```

Rename `.env.sample` to `.env`.

Edit `.env` file to specify credentials.

`RINGCENTRAL_RECEIVER` is a phone number to receive SMS, Fax..etc.

Run `bundle exec rspec`


## License

MIT
