Gem::Specification.new do |gem|
  gem.name          = 'ringcentral-sdk'
  gem.version       = '0.2.2'
  gem.authors       = ['Tyler Liu']
  gem.email         = ['tyler.liu@ringcentral.com']
  gem.description   = 'Ruby SDK for you to access RingCentral platform API.'
  gem.summary       = 'RingCentral Ruby SDK.'
  gem.homepage      = 'https://github.com/tylerlong/ringcentral-ruby'
  gem.license       = 'MIT'

  gem.require_paths = ['lib']
  gem.files         = %w(Rakefile README.md ringcentral-sdk.gemspec)
  gem.files        += Dir['lib/**/*.rb']
  gem.test_files    = Dir['test/**/*.rb']

  gem.add_dependency('rest-client', '~> 2.0', '>= 2.0.2')
  gem.add_dependency('addressable', '~> 2.5', '>= 2.5.2')
  gem.add_dependency('concurrent-ruby', '~> 1.0', '>= 1.0.2')
  gem.add_dependency('pubnub', '~> 4.0', '>= 4.0.27')
end
