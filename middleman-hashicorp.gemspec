# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-hashicorp/version'

Gem::Specification.new do |spec|
  spec.name          = 'middleman-hashicorp'
  spec.version       = Middleman::HashiCorp::VERSION
  spec.authors       = ['HashiCorp, Inc.']
  spec.summary       = 'A series of helpers for consistency among HashiCorp\'s middleman sites'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/hashicorp/middleman-hashicorp'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  # Middleman
  spec.add_dependency 'middleman',            '~> 3.4'
  spec.add_dependency 'middleman-livereload', '~> 3.4'
  spec.add_dependency 'middleman-syntax',     '~> 3.0'

  # Assets
  spec.add_dependency 'bootstrap-sass', '~> 3.3'
  spec.add_dependency 'builder',        '~> 3.2'
  spec.add_dependency 'redcarpet',      '~> 3.3'

  # Turbolinks
  spec.add_dependency 'turbolinks', '~> 5.0'

  # Development dependencies
  spec.add_development_dependency 'rspec', '~> 3.5'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake',    '~> 11.3'
end
