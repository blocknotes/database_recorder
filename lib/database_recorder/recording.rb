# frozen_string_literal: true

require 'forwardable'

module DatabaseRecorder
  class Recording
    attr_accessor :cache
    attr_reader :queries, :started

    def initialize(options: {})
      (@@instances ||= {})[Process.pid] = self
      @cache = nil
      @queries = []
      @search_index = 0
    end

    def cached_query_for(sql)
      current = @search_index
      match = cache[@search_index..].find do |item|
        current += 1
        item['sql'] == sql # TODo: try matching by normalized query (no values)
      end
      return unless match

      @search_index = current
      match

      # cache.shift # TMP
    end

    def push(sql:, binds:, result:)
      serialize = result ? { 'count' => result.count, 'fields' => result.fields, 'values' => result.values } : nil
      query = { 'sql' => sql, 'binds' => binds, 'result' => serialize }
      @queries.push(query)
    end

    def start
      @started = true
      yield
      @started = false
    end

    class << self
      extend Forwardable

      def_delegators :current_instance, :cache, :cached_query_for, :push

      def current_instance
        (@@instances ||= {})[Process.pid]
      end

      def started?
        current_instance&.started
      end
    end
  end
end
