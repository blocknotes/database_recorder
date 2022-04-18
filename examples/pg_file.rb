# frozen_string_literal: true

require 'pg'
require_relative '../lib/database_recorder'

DB_CONFIG = {
  host: ENV['DB_HOST'],
  dbname: ENV['DB_NAME'],
  user: ENV['DB_USERNAME'],
  password: ENV['DB_PASSWORD']
}.freeze

# Setup
DatabaseRecorder::Config.db_driver = :pg
DatabaseRecorder::Config.print_queries = true
DatabaseRecorder::Config.storage = :file
DatabaseRecorder::Config.storage_options = { recordings_path: './recordings' }

DatabaseRecorder::Core.setup

puts '>>> Recording'
result = DatabaseRecorder::Recording.new(options: { name: 'pg_file' }).start do
  PG.connect(DB_CONFIG).exec("INSERT INTO tags(name, created_at, updated_at) VALUES('tag1', NOW(), NOW())")
  PG.connect(DB_CONFIG).exec("SELECT * FROM tags")
end

puts '>>> Recorded data'
pp result

puts '>>> Stored files'
pp Dir['recordings/*.yml']
