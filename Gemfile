# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :development, :test do
  gem 'mysql2'
  gem 'pg'
  gem 'rails'
  gem 'redis'
  gem 'sprockets'

  # Testing
  gem 'factory_bot_rails'
  gem 'rspec-rails'

  # Linters
  gem 'fasterer'
  gem 'rubocop'
  gem 'rubocop-rspec'

  # Misc
  gem 'pry'
end
