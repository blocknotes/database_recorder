# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  enable_coverage :branch
  # primary_coverage :branch
end

require 'spec_helper'

ENV['RAILS_ENV'] = 'test'
require File.expand_path('dummy/config/environment.rb', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'pry'
require 'rspec/rails'

# require 'capybara/rails'

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

# Force deprecations to raise an exception.
ActiveSupport::Deprecation.behavior = :raise

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures = false
  config.render_views = false

  config.color = true
  config.tty = true

  config.before(:suite) do
    intro = ('-' * 80)
    intro << "\n"
    intro << "- Ruby:        #{RUBY_VERSION}\n"
    intro << "- Rails:       #{Rails.version}\n"
    intro << "- Database:    #{ActiveRecord::Base.connection_db_config.adapter}\n"
    intro << ('-' * 80)

    RSpec.configuration.reporter.message(intro)
  end

  config.before do
    DatabaseRecorder::Config.load_defaults
  end

  config.after do
    DatabaseRecorder::Config.load_defaults
  end
end
