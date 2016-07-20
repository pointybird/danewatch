# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'danewatch/version'

Gem::Specification.new do |spec|
  spec.name          = 'danewatch'
  spec.version       = DaneWatch::VERSION
  spec.authors       = ['Steve Clark']
  spec.email         = ['']

  spec.summary       = 'A script for checking for changes to listings for dogs available through Rocky Mountain Great Dane Rescue.'
  spec.homepage      = 'http://github.com/pointybird/danewatch'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)
  spec.metadata['allowed_push_host'] = ''

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'clockwork'
  spec.add_dependency 'daemons'
  spec.add_dependency 'hashdiff'
  spec.add_dependency 'log4r'
  spec.add_dependency 'mechanize'
  spec.add_dependency 'gmail'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '3.0'
  spec.add_development_dependency 'rubocop'
end
