# frozen_string_literal: true

require_relative 'database_recorder/core'

if defined? ::ActiveRecord
  require_relative 'database_recorder/activerecord/abstract_adapter_ext'
  require_relative 'database_recorder/activerecord/base_ext'
  require_relative 'database_recorder/activerecord/recorded_result'
  require_relative 'database_recorder/activerecord/recorder'
end

if defined? ::Mysql2
  require_relative 'database_recorder/mysql2/recorded_result'
  require_relative 'database_recorder/mysql2/recorder'
end

if defined? ::PG
  require_relative 'database_recorder/pg/recorded_result'
  require_relative 'database_recorder/pg/recorder'
end

require_relative 'database_recorder/storage/file'
require_relative 'database_recorder/storage/redis'

require_relative 'database_recorder/rspec'
require_relative 'database_recorder/recording'
require_relative 'database_recorder/config'
