Gem::Specification.new do |gem|
  gem.name          = 'ringcentral-sdk'
  gem.version       = '1.1.3'
  gem.authors       = ['Tyler Liu']
  gem.email         = ['tyler.liu@ringcentral.com']
  gem.description   = 'This is the **official** RingCentral SDK for the Ruby programming language. While there are other Ruby SDKs for RingCentral, those are maintained by the community. We\'re including this clarification to help avoid confusion, as some SDKs have similar names. That said, we truly appreciate and welcome community contributions and alternative SDKs.'
  gem.summary       = 'The **official** RingCentral Ruby SDK.'
  gem.homepage      = 'https://github.com/ringcentral/ringcentral-ruby'
  gem.license       = 'MIT'

  gem.require_paths = ['lib']
  gem.files         = %w(README.md ringcentral-sdk.gemspec)
  gem.files        += Dir['lib/**/*.rb']
  gem.test_files    = Dir['spec/**/*.rb']

  gem.add_dependency('addressable', '~> 2.9', '>= 2.9.2')
  gem.add_dependency('concurrent-ruby', '~> 1.3', '>= 1.3.8')
  gem.add_dependency('faraday', '~> 2.15', '>= 2.15.1')
  gem.add_dependency('faraday-multipart', '~> 1.2', '>= 1.2.0')
  gem.add_dependency('faye-websocket', '~> 0.12', '>= 0.12.0')
end
