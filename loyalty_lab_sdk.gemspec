require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'loyalty_lab_sdk', 'version'))

Gem::Specification.new do |s|

  # definition
  s.name = %q{loyalty_lab_sdk}
  s.version = LoyaltyLabSDK::VERSION

  # details
  s.date = %q{2012-01-09}
  s.summary = %q{Library for accessing the Loyalty Lab API.}
  s.description = %q{Full documentation of the API is at http://api.loyaltylab.com/loyaltyapi/help/index.html.}
  s.authors = [ 'David Dawson' ]
  s.email = %q{david@stashrewards.com}
  s.homepage = %q{http://www.stashrewards.com}
  s.require_paths = [ 'lib' ]
  
  # documentation
  s.has_rdoc = true
  s.extra_rdoc_files = %w( README.rdoc CHANGELOG.rdoc )
  s.rdoc_options = %w( --main README.rdoc )

  # files to include
  s.files = Dir[ 'lib/**/*.rb', 'README.rdoc', 'CHANGELOG.rdoc' ]

  # dependencies
  s.add_dependency 'savon', '~> 0.9'

  # if binaries
  # s.bindir = 'bin'
  # s.executables = [ 'executable' ]

end
