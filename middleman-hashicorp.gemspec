# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-hashicorp/version'

Gem::Specification.new do |spec|
  spec.name          = 'middleman-hashicorp'
  spec.version       = Middleman::HashiCorp::VERSION
  spec.authors       = ['Seth Vargo']
  spec.email         = ['sethvargo@gmail.com']
  spec.summary       = 'A series of helpers for consistency among HashiCorp\'s middleman sites'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/hashicorp/middleman-hashicorp'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.0.0'

  # Middleman
  spec.add_dependency 'middleman',             '~> 3.4'
  spec.add_dependency 'middleman-minify-html', '~> 3.4'
  spec.add_dependency 'middleman-livereload',  '~> 3.4'
  spec.add_dependency 'middleman-syntax',      '~> 2.0'

  # Assets
  spec.add_dependency 'bootstrap-sass', '~> 3.3'
  spec.add_dependency 'builder',        '~> 3.2'
  spec.add_dependency 'less',           '~> 2.6'
  spec.add_dependency 'redcarpet',      '~> 3.2'
  spec.add_dependency 'therubyracer',   '~> 0.12'

  # Server
  spec.add_dependency 'rack-contrib',      '~> 1.2'
  spec.add_dependency 'rack-protection',   '~> 1.5'
  spec.add_dependency 'rack-rewrite',      '~> 1.5'
  spec.add_dependency 'thin',              '~> 1.6'
  spec.add_dependency 'rack-ssl-enforcer', '~> 0.2'

  # Development dependencies
  spec.add_development_dependency 'rspec', '~> 3.2'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake',    '~> 10.4'
end
