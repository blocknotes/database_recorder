# frozen_string_literal: true

require 'forwardable'
require 'singleton'

module DatabaseRecorder
  class Config
    include Singleton

    attr_accessor :db_driver, :print_queries, :replay_recordings, :storage

    class << self
      extend Forwardable

      def_delegators :instance, :db_driver, :db_driver=, :print_queries, :print_queries=, :replay_recordings,
                     :replay_recordings=, :storage

      def load_defaults
        instance.print_queries = false # false | true | :color
        instance.replay_recordings = false
        self.storage = :file # :file | :redis
      end

      def storage=(value)
        instance.storage =
          case value
          when :file then DatabaseRecorder::Storage::File
          when :redis then DatabaseRecorder::Storage::Redis
          else raise ArgumentError, "Unknown storage: #{value}"
          end
      end
    end
  end
end

DatabaseRecorder::Config.load_defaults
