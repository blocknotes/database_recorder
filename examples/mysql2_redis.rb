# frozen_string_literal: true

require 'mysql2'
require 'redis'
require_relative '../lib/database_recorder'

DB_CONFIG = {
  host: ENV['DB_HOST'],
  database: ENV['DB_NAME'],
  username: ENV['DB_USERNAME'],
  password: ENV['DB_PASSWORD']
}.freeze

# Setup
DatabaseRecorder::Config.db_driver = :mysql2
DatabaseRecorder::Config.print_queries = true
DatabaseRecorder::Config.storage = :redis
DatabaseRecorder::Config.storage_options = { connection: Redis.new }

DatabaseRecorder::Core.setup

# Recording
DatabaseRecorder::Recording.new(options: { name: 'mysql2_redis' }).tap do |recording|
  puts '>>> Start recording'
  result = recording.start do
    ::Mysql2::Client.new(DB_CONFIG).query("INSERT INTO tags(name, created_at, updated_at) VALUES('tag1', NOW(), NOW())")
    ::Mysql2::Client.new(DB_CONFIG).query("SELECT * FROM tags")
  end
  puts '>>> Finish recording'
  pp result
end

puts '>>> Recordings'
pp Redis.new.keys
