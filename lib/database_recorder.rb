# frozen_string_literal: true

require_relative 'database_recorder/core'

if defined? ::ActiveRecord
  require_relative 'database_recorder/activerecord/abstract_adapter_ext'
  require_relative 'database_recorder/activerecord/base_ext'
  require_relative 'database_recorder/activerecord/recorded_result'
  require_relative 'database_recorder/activerecord/recorder'
end

require_relative 'database_recorder/mysql2/recorded_result'
require_relative 'database_recorder/mysql2/recorder'

require_relative 'database_recorder/pg/recorded_result'
require_relative 'database_recorder/pg/recorder'

require_relative 'database_recorder/storage/base'
require_relative 'database_recorder/storage/file'
require_relative 'database_recorder/storage/redis'

require_relative 'database_recorder/rspec'
require_relative 'database_recorder/recording'
require_relative 'database_recorder/config'
