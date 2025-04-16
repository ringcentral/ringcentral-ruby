## Update all dependencies

```
bundle update
```

## Test

```
bundle exec rspec
```

### Run a specific test case

```
bundle exec rspec spec/path/to/test.rb
```

## Deploy

Update version number in `ringcentral-sdk.gemspec`.

```
gem build ringcentral-sdk.gemspec
gem push ringcentral-sdk-<version>.gem
```
