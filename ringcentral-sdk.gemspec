require File.expand_path('../lib/ringcentral/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'ringcentral-sdk'
  gem.version       = RingCentral::VERSION
  gem.authors       = ['Tyler Liu']
  gem.email         = ['tyler.liu@ringcentral.com']
  gem.description   = 'RingCentral Ruby SDK.'
  gem.summary       = 'Ruby SDK for you to access RingCentral platform API.'
  gem.homepage      = 'https://github.com/tylerlong/ringcentral-ruby'
  gem.license       = 'MIT'

  gem.require_paths = ['lib']
  gem.files         = %w(.yardopts README.md ringcentral-sdk.gemspec)
  gem.files += Dir['lib/**/*.rb']
  gem.files += Dir['spec/**/*.rb']
  gem.test_files = Dir['spec/**/*.rb']

  gem.add_dependency('rest-client', '>= 2.0.2')
end
