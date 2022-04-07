# frozen_string_literal: true

module DatabaseRecorder
  module Mysql2
    module Recorder
      def query(sql, options = {})
        Mysql2.record(self, sql: sql) do
          super
        end
      end
    end

    module_function

    def ignore_query?(sql)
      !Recording.started? ||
        sql == 'SELECT LAST_INSERT_ID() AS _dbr_last_insert_id' ||
        sql.downcase.match?(/\A(begin|commit|release|rollback|savepoint|show full fields from)/i) ||
        sql.match?(/information_schema.statistics/)
    end

    def record(recorder, sql:)
      return yield if ignore_query?(sql)

      Core.log_query(sql)
      if Config.replay_recordings && !Recording.cache.nil?
        Recording.push(sql: sql)
        data = Recording.cached_query_for(sql)
        return yield unless data # cache miss

        RecordedResult.new.prepare(data['result'].slice('count', 'fields', 'values')) if data['result']
      else
        yield.tap do |result|
          result_data =
            if result
              { 'count' => result.count, 'fields' => result.fields, 'values' => result.to_a }
            else
              last_insert_id = recorder.query('SELECT LAST_INSERT_ID() AS _dbr_last_insert_id').to_a
              { 'count' => last_insert_id.count, 'fields' => ['id'], 'values' => last_insert_id }
            end

          Recording.push(sql: sql, result: result_data)
        end
      end
    end

    def setup
      ::Mysql2::Client.class_eval do
        prepend Recorder
      end
    end
  end
end
