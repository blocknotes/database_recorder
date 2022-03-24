# frozen_string_literal: true

require 'forwardable'
require 'singleton'

module DatabaseRecorder
  class Config
    include Singleton

    attr_accessor :print_queries, :replay_recordings, :storage

    class << self
      extend Forwardable

      def_delegators :instance, :print_queries, :print_queries=, :replay_recordings, :replay_recordings=, :storage, :storage=

      def load_defaults
        instance.print_queries = false # false | true | :color
        instance.replay_recordings = false
        instance.storage = DatabaseRecorder::Storage::File
      end
    end
  end
end

DatabaseRecorder::Config.load_defaults
