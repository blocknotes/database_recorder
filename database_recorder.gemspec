# frozen_string_literal: true

require_relative 'lib/database_recorder/version'

Gem::Specification.new do |spec|
  spec.platform    = Gem::Platform::RUBY
  spec.name        = 'database_recorder'
  spec.version     = DatabaseRecorder::VERSION
  spec.summary     = 'A SQL database recorder'
  spec.description = 'Record application queries, verify them against stored queries, and replay them.'

  spec.authors     = ['Mattia Roccoberton']
  spec.email       = ['mat@blocknot.es']
  spec.homepage    = 'https://github.com/blocknotes/database_recorder'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/blocknotes/database_recorder'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*', 'MIT-LICENSE', 'README.md']

  spec.required_ruby_version = '>= 2.6.0'

  spec.add_runtime_dependency 'coderay', '~> 1.1'
end
