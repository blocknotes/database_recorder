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

      def record(sql:, binds: nil, source: nil)
        return yield if ignore_query?(sql)

        Core.log_query(sql, source)
        if Config.replay_recordings && !Recording.cache.nil?
          Recording.push(sql: sql, binds: binds)
          data = Recording.cached_query_for(sql)
          return yield unless data # cache miss

          RecordedResult.new(data['result'].slice('count', 'fields', 'values'))
        else
          yield.tap do |result|
            result_data = result ? { 'count' => result.count, 'fields' => result.fields, 'values' => result.values } : nil
            Recording.push(sql: sql, binds: binds, result: result_data)
          end
        end
      end

      def setup
        ::PG::Connection.class_eval do
          prepend ConnectionExt
        end
      end
    end
  end
end
