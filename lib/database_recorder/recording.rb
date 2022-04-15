# frozen_string_literal: true

require 'forwardable'

module DatabaseRecorder
  class Recording
    attr_accessor :cache, :entities, :metadata
    attr_reader :from_cache, :options, :prepared_queries, :queries, :started

    def initialize(options: {})
      (@@instances ||= {})[Process.pid] = self
      @cache = nil
      @entities = []
      @metadata = {}
      @options = options
      @queries = []
      @search_index = 0
      @@prepared_queries ||= {}
    end

    def cached_query_for(sql)
      current = @search_index
      match = cache[@search_index..].find do |item|
        current += 1
        item['sql'] == sql
      end
      return unless match

      @search_index = current
      match

      # cache.shift # TMP
    end

    def new_entity(model:, id:)
      @entities.push('model' => model, 'id' => id)
    end

    def pull_entity
      @entities.shift
    end

    def push(sql:, name: nil, binds: nil, result: nil, source: nil)
      query = { 'name' => name, 'sql' => sql, 'binds' => binds, 'result' => result }.compact
      @queries.push(query)
    end

    def push_prepared(name: nil, sql: nil, binds: nil, result: nil, source: nil)
      query = { 'name' => name, 'sql' => sql, 'binds' => binds, 'result' => result }.compact
      @@prepared_queries[name || sql] = query
    end

    def start
      @started = true
      storage = Config.storage&.new(self, name: options[:name])
      @from_cache = storage&.load
      yield
      storage&.save unless from_cache
      @started = false
      result = { current_queries: queries.map { _1['sql'] } }
      result[:stored_queries] = cache.map { _1['sql'] } if from_cache
      result
    end

    def update_prepared(name: nil, sql: nil, binds: nil, result: nil, source: nil)
      query = @@prepared_queries[name || sql]
      query['sql'] = sql if sql
      query['binds'] = binds if binds
      query['result'] = result if result
      @queries.push(query)
      query
    end

    class << self
      extend Forwardable

      def_delegators :current_instance, :cache, :cached_query_for, :from_cache, :new_entity, :prepared_queries,
                     :pull_entity, :push, :push_prepared, :queries, :update_prepared

      def current_instance
        (@@instances ||= {})[Process.pid]
      end

      def started?
        current_instance&.started
      end
    end
  end
end
