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

rc = RingCentral.new(ENV['appKey'], ENV['appSecret'], ENV['server'])
rc.authorize(username: ENV['username'], extension: ENV['extension'], password: ENV['password'])

# get
r = rc.get('/restapi/v1.0/account/~/extension/~')
expect(r).not_to be_nil
expect('101').to eq(JSON.parse(r.body)['extensionNumber'])
```


For more sample code, please refer to the [test cases](/spec).


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

Run `rspec`


## License

MIT


## Todo

- Batch requests
