# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sneakers/laces/version'

Gem::Specification.new do |spec|
  spec.name     = 'sneakers-laces'
  spec.version  = Sneakers::Laces::VERSION
  spec.authors  = ['Rustam Sharshenov']
  spec.email    = ['rustam@sharshenov.com']

  spec.summary      = 'Configure your Sneakers worker on-the-fly'
  spec.description  = 'Subscribe your Sneakers workers to queues by name regexes without process restart'
  spec.homepage     = 'https://github.com/sharshenov/sneakers-laces'
  spec.license      = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ['lib']

  spec.add_dependency 'rabbitmq_http_api_client'
  spec.add_dependency 'sneakers'

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
end
