Gem::Specification.new do |gem|
  gem.name          = 'ringcentral-sdk'
  gem.version       = '0.9.9'
  gem.authors       = ['Tyler Liu']
  gem.email         = ['tyler.liu@ringcentral.com']
  gem.description   = 'Ruby SDK for you to access RingCentral platform API.'
  gem.summary       = 'RingCentral Ruby SDK.'
  gem.homepage      = 'https://github.com/ringcentral/ringcentral-ruby'
  gem.license       = 'MIT'

  gem.require_paths = ['lib']
  gem.files         = %w(README.md ringcentral-sdk.gemspec)
  gem.files        += Dir['lib/**/*.rb']
  gem.test_files    = Dir['spec/**/*.rb']

  gem.add_dependency('addressable', '~> 2.8', '>= 2.8.4')
  gem.add_dependency('concurrent-ruby', '~> 1.2', '>= 1.2.2')
  gem.add_dependency('pubnub', '~> 5.2', '>= 5.2.2')
  gem.add_dependency('faraday', '~> 2.7', '>= 2.7.4')
  gem.add_dependency('faraday-multipart', '~> 1.0', '>= 1.0.4')
end
