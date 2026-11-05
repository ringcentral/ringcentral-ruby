# Official RingCentral SDK for Ruby

[![Reference](https://img.shields.io/badge/rubydoc-reference-blue?logo=ruby)](https://ringcentral.github.io/ringcentral-ruby/)
[![Twitter](https://img.shields.io/twitter/follow/ringcentraldevs.svg?style=social&label=follow)](https://twitter.com/RingCentralDevs)

**[RingCentral Developers](https://developer.ringcentral.com/api-products)** is
a cloud communications platform which can be accessed via more than 70 APIs. The
platform's main capabilities include technologies that enable:
**[Voice](https://developer.ringcentral.com/api-products/voice),
[SMS/MMS](https://developer.ringcentral.com/api-products/sms),
[Fax](https://developer.ringcentral.com/api-products/fax),
[Glip Team Messaging](https://developer.ringcentral.com/api-products/team-messaging),
[Data and Configurations](https://developer.ringcentral.com/api-products/configuration)**.

## Additional resources

- [RingCentral API Reference](https://developer.ringcentral.com/api-docs/latest/index.html) -
  an interactive reference for the RingCentral API that allows developers to
  make API calls with no code.
- [Document](https://ringcentral.github.io/ringcentral-ruby/) - an interactive
  reference for the SDK code documentation.

## Getting help and support

If you are having difficulty using this SDK, or working with the RingCentral
API, please visit our
[developer community forums](https://community.ringcentral.com/spaces/144/) for
help and to get quick answers to your questions. If you wish to contact the
RingCentral Developer Support team directly, please
[submit a help ticket](https://developers.ringcentral.com/support/create-case)
from our developer website.

## Official VS. Community maintained SDKs

This is the **official** RingCentral SDK for the Ruby programming language.
While there are other Ruby SDKs for RingCentral, those are maintained by the
community. We’re including this clarification to help avoid confusion, as some
SDKs have similar names. That said, we truly appreciate and welcome community
contributions and alternative SDKs.

## Installation

```
gem install ringcentral-sdk
```

If for some reason `eventmachine` failed to install, please check
[this](https://stackoverflow.com/a/31516586/862862).

Please note that, there is a gem with a similar name "ringcentral_sdk" which is
not maintained by us. Please make sure that you install the correct gem.

### Name collision with `ringcentral` gem

The `ringcentral` gem is using RingCentral's legacy API which was End-of-Lifed
in 2018. Everyone is recommended to move to the REST API.

If you have both the `ringcentral` and `ringcentral-sdk` gems installed, you
will run into a collision error when attempting to initialize the
`ringcentral-sdk` RingCentral SDK.

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

## Samples

For more code samples, please refer to the test cases in `spec` folder.

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

Above will be translated to
`/restapi/v1.0/account/~/extension?hello=world1&hello=world2`.

### Token Refresh

Access token expires. You need to call `rc.refresh()` before it expires. If you
want the SDK to do auto refresh please `rc.auto_refresh = true` before
authorization.

### Load pre-existing token

Let's say you already have a token. Then you can load it like this:
`rc.token = your_token_object`. The benefit of loading a preexisting token is
you don't need to go through any authorization flow.

If what you have is a JSON string instead of a Ruby object, you need to convert
it first: `JSON.parse(your_token_string)`.

If you only have a string for the access token instead of for the whole object,
you can set it like this:

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

- Absolute time out. The maximum time for a subscription to run is 24 hours.
  After that, the websocket connection will be closed by the server.
- Network issue. It could be your local network issue or the server's network
  issue. In either case, your websocket connection will be closed

In order to keep a subscription running 24 * 7, you need to re-subscribe when
the connection is closed.

```ruby
subscription.on_ws_closed = lambda { |event|
  # make sure that there is no network issue and re-subscribe
  subscription.subscribe()
}
```

## How to test

Use Ruby 3.3, 3.4 or 4.0 (the supported CI matrix). Install dependencies with
`bundle install`, then copy `.env.sample` to `.env`
and fill in every value:

- `RINGCENTRAL_SERVER_URL`: API server (production by default in the sample).
- `RINGCENTRAL_CLIENT_ID` and `RINGCENTRAL_CLIENT_SECRET`: application credentials.
- `RINGCENTRAL_JWT_TOKEN`: JWT for the test extension.
- `RINGCENTRAL_SENDER`: the test extension's SMS/MMS-capable phone number.
- `RINGCENTRAL_RECEIVER`: a phone number that can receive the test SMS/MMS and fax.

Keep real credentials and phone numbers in the ignored `.env` file. Values in
that file override inherited environment variables. RSpec automatically loads
`spec/spec_helper.rb` through `.rspec`; the helper starts coverage before loading
the SDK and loads dotenv for every spec.

Run the complete suite from the repository root:

```sh
bundle exec rspec
```

The default suite makes live API calls: it sends fax, MMS and pager messages,
changes message read/deletion state, uploads and applies a voicemail greeting,
and opens WebSocket subscriptions. Use a dedicated test account and agreed
recipient. Run suites sharing the account, recipient or greeting sequentially.
The greeting example uses the SDK's existing multipart upload functionality.
WebSocket examples wait for a new active subscription before sending, allow up to
30 seconds for each notification, and observe revoked subscriptions for 30 seconds.
Cleanup runs even when an assertion fails.

Select a single file or example by line number with the same shared setup:

```sh
bundle exec rspec spec/ringcentral_spec.rb
bundle exec rspec spec/ringcentral_spec.rb:15
```

Coverage is written to `coverage/index.html` for both full and selected runs.
A selected run measures only the SDK code exercised by those examples.

### Continuous integration

Normal push/PR CI and release-tag validation run the complete live suite on Ruby
3.3, 3.4 and 4.0. Matrix entries run sequentially against the shared account,
recipient and greeting. This limit applies within each workflow run: maintainers
must also avoid overlapping test workflows, release workflows and local suites
using the same account. Wait for the active run to finish before starting another.
Coverage artifacts are named by Ruby version; missing coverage fails the job.
Release publication runs once, only after every release-matrix entry succeeds.

Both workflows use the `prod` environment and require all six `RINGCENTRAL_*`
variables listed above as secrets. Before tests run, missing values fail the job
with variable names only. Maintainers must configure secrets and environment
access/approval rules for trusted code; never approve untrusted PR code for access
to the test account. Ordinary `pull_request` events are retained: fork PRs cannot
receive the repository's secrets, so their full-suite CI will fail clearly until
trusted changes can be validated in an authorized context. No privileged PR
trigger runs untrusted code with credentials.

[Dependabot does not receive ordinary Actions secrets](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-on-actions). Maintainers must provision
separately supported Dependabot secrets and check the `prod` environment's access
rules if trusted Dependabot runs are to execute the full suite. If the event or
environment cannot supply credentials, CI fails rather than skipping live tests.
Environment protections remain in force; no secret values belong in PRs or logs.

## License

MIT
