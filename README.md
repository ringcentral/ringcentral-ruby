# RingCentral Ruby SDK


## Installation

Add `gem 'ringcentral-sdk'` to `Gemfile` and run `bundle install`.


## Documentation

https://developer.ringcentral.com/api-docs/latest/index.html


## Usage

```ruby
require 'ringcentral'

rc = RingCentral.new(ENV['appKey'], ENV['appSecret'], ENV['server'])
rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])

# get
r = rc.get('/restapi/v1.0/account/~/extension/~')
assert_not_equal nil, r
assert_equal '101', JSON.parse(r.body)['extensionNumber']
```


For more sample code, please refer to the [test cases](/test).


## How to test

Create `.env` file with the following content:

```
production=false
server=https://platform.devtest.ringcentral.com
appKey=appKey
appSecret=appSecret
username=username
extension=extension
password=password
receiver=number-to-receiver-sms
```

Run `rake test`


## License

MIT


## Todo

- Travis CI
- code coverage
- PubNub subscription
