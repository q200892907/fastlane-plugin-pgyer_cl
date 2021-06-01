# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/pgyer_cl/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-pgyer_cl'
  spec.version       = Fastlane::PgyerCl::VERSION
  spec.author        = %q{chenlei}
  spec.email         = %q{200892907@qq.com}

  spec.summary       = %q{pgyer_cl}
  #spec.homepage      = "https://github.com/q200892907/fastlane-plugin-pgyer_cl"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 2.28.3'
end
