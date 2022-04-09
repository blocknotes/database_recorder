# frozen_string_literal: true

require 'forwardable'
require 'singleton'

module DatabaseRecorder
  class Config
    include Singleton

    DEFAULT_DB_DRIVER = :active_record
    DEFAULT_STORAGE = DatabaseRecorder::Storage::File

    DB_DRIVER_VALUES = %i[active_record mysql2 pg].freeze
    PRINT_QUERIES_VALUES = [false, true, :color].freeze
    STORAGE_VALUES = {
      file: DatabaseRecorder::Storage::File,
      redis: DatabaseRecorder::Storage::Redis
    }.freeze

    attr_accessor :db_driver, :print_queries, :replay_recordings, :storage

    class << self
      extend Forwardable

      def_delegators :instance, :db_driver, :print_queries, :replay_recordings, :replay_recordings=, :storage

      def load_defaults
        instance.db_driver = DEFAULT_DB_DRIVER
        instance.print_queries = false
        instance.replay_recordings = false
        instance.storage = DEFAULT_STORAGE
      end

      def db_driver=(value)
        instance.db_driver = DB_DRIVER_VALUES.include?(value) ? value : DEFAULT_DB_DRIVER
      end

      def print_queries=(value)
        instance.print_queries = PRINT_QUERIES_VALUES.include?(value) ? value : false
      end

      def storage=(value)
        instance.storage =
          if value.is_a?(Class) && value < Storage::Base
            value
          else
            STORAGE_VALUES[value]
          end
      end
    end
  end
end

DatabaseRecorder::Config.load_defaults
