# frozen_string_literal: true

module DatabaseRecorder
  module PG
    module Recorder
      module_function

      def ignore_query?(sql)
        !Recording.started? ||
          sql.downcase.match?(/\A(begin|commit|release|rollback|savepoint)/i) ||
          sql.match?(/ pg_attribute |SHOW max_identifier_length|SHOW search_path/)
      end

      def format_result(result)
        { 'count' => result.count, 'fields' => result.fields, 'values' => result.values } if result
      end

      def prepare_statement(sql: nil, name: nil, binds: nil, source: nil)
        Recording.push_prepared(name: name, sql: sql, binds: binds, source: source)
        yield if !Config.replay_recordings || Recording.cache.nil?
      end

      def setup
        ::PG::Connection.class_eval do
          prepend ConnectionExt
        end
      end

      def store_prepared_statement(name: nil, sql: nil, binds: nil, source: nil)
        if Config.replay_recordings && !Recording.cache.nil?
          data = Recording.cache.find { |query| query['name'] == name }
          return yield unless data # cache miss

          Core.log_query(data['sql'], source)
          Recording.push(sql: data['sql'], binds: data['binds'], source: source)
          RecordedResult.new(data['result'].slice('count', 'fields', 'values'))
        else
          Core.log_query(sql, source)
          yield.tap do |query_result|
            result = format_result(query_result)
            query = Recording.update_prepared(name: name, sql: sql, binds: binds, result: result, source: source)
            Core.log_query(query['sql'], source)
          end
        end
      end

      def store_query(name: nil, sql: nil, binds: nil, source: nil)
        return yield if ignore_query?(sql)

        Core.log_query(sql, source)
        @prepared_statement = nil
        if Config.replay_recordings && !Recording.cache.nil?
          Recording.push(sql: sql, binds: binds, source: source)
          data = Recording.cached_query_for(sql)
          return yield unless data # cache miss

          RecordedResult.new(data['result'].slice('count', 'fields', 'values'))
        else
          yield.tap do |result|
            Recording.push(name: name, sql: sql, binds: binds, result: format_result(result), source: source)
          end
        end
      end
    end
  end
end
