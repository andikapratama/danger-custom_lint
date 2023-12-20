# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = 'danger-flutter_custom_lint'
  spec.version       = FlutterCustomLint::VERSION
  spec.authors       = ['Andika Pratama']
  spec.email         = ['andika@bukalapak.com']
  spec.summary       = 'A Danger Plugin to lint dart files using custom_lint.'
  spec.homepage      = 'https://github.com/mateuszszklarek/danger-flutterlint'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'danger-plugin-api', '~> 1.0'

  spec.add_development_dependency 'codecov', '~> 0.6.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.3'
  spec.add_development_dependency 'rake', '~> 13.0.6'
  spec.add_development_dependency 'rb-readline', '~> 0.5.5'
  spec.add_development_dependency 'rspec', '~> 3.11.0'
  spec.add_development_dependency 'rubocop', '~> 1.25.1'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
end
