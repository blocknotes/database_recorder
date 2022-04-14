# frozen_string_literal: true

module DatabaseRecorder
  module Mysql2
    module Recorder
      module_function

      def ignore_query?(sql)
        !Recording.started? ||
          sql == 'SELECT LAST_INSERT_ID() AS _dbr_last_insert_id' ||
          sql.downcase.match?(/\A(begin|commit|release|rollback|savepoint|show full fields from)/i) ||
          sql.match?(/information_schema.statistics/)
      end

      def format_result(result)
        { 'count' => result.count, 'fields' => result.fields, 'values' => result.to_a } if result.is_a?(::Mysql2::Result)
        # else
        #   last_insert_id = adapter.query('SELECT LAST_INSERT_ID() AS _dbr_last_insert_id').to_a
        #   { 'count' => last_insert_id.count, 'fields' => ['id'], 'values' => last_insert_id }
      end

      def prepare_statement(adapter, sql: nil, name: nil, binds: nil, source: nil)
        @last_prepared = Recording.push_prepared(name: name, sql: sql, binds: binds, source: source)
        yield if !Config.replay_recordings || Recording.cache.nil?
      end

      def setup
        ::Mysql2::Client.class_eval do
          prepend ClientExt
        end

        ::Mysql2::Statement.class_eval do
          prepend StatementExt
        end
      end

      def store_prepared_statement(adapter, source:, binds:)
        # sql = @last_prepared&.send(:[], 'sql')
        sql = @last_prepared['sql']
        Core.log_query(sql, source)
        if Config.replay_recordings && !Recording.cache.nil?
          data = Recording.cache.find { |query| query['sql'] == sql }
          return yield unless data # cache miss

          Recording.push(sql: data['sql'], binds: data['binds'], source: source)
          RecordedResult.new(data['result'].slice('count', 'fields', 'values'))
        else
          yield.tap do |result|
            Recording.update_prepared(sql: sql, binds: binds, result: format_result(result), source: source)
          end
        end
      end

      def store_query(adapter, sql:, source:)
        return yield if ignore_query?(sql)

        Core.log_query(sql, source)
        if Config.replay_recordings && !Recording.cache.nil?
          Recording.push(sql: sql, source: source)
          data = Recording.cached_query_for(sql)
          return yield unless data # cache miss

          RecordedResult.new.prepare(data['result'].slice('count', 'fields', 'values')) if data['result']
        else
          yield.tap do |result|
            Recording.push(sql: sql, result: format_result(result), source: source)
          end
        end
      end
    end
  end
end
