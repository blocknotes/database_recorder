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

# Recording
DatabaseRecorder::Recording.new(options: { name: 'pg_file' }).tap do |recording|
  puts '>>> Start recording'
  result = recording.start do
    PG.connect(DB_CONFIG).exec("INSERT INTO tags(name, created_at, updated_at) VALUES('tag1', NOW(), NOW())")
    PG.connect(DB_CONFIG).exec("SELECT * FROM tags")
  end
  puts '>>> Finish recording'
  pp result
end

puts '>>> Recordings'
pp Dir['recordings/*.yml']
