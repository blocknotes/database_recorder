# frozen_string_literal: true

module DatabaseRecorder
  module Postgres
    module Recorder
      def async_exec(sql)
        Postgres.record(sql: sql, source: :async_exec) do
          super
        end
      end

      def sync_exec(sql)
        Postgres.record(sql: sql, source: :sync_exec) do
          super
        end
      end

      # def exec(*args)
      #   puts "-E- #{args[0]}"
      #   super
      # end

      # def query(*args)
      #   puts "-Q- #{args[0]}"
      #   super
      # end

      def exec_params(*args)
        Postgres.record(sql: args[0], binds: args[1], source: :exec_params) do
          super
        end
      end

      # def async_exec_params(*args)
      #   puts ">>> #{args[0]}"
      #   super
      # end

      # def sync_exec_params(*args)
      #   puts ">>> #{args[0]}"
      #   super
      # end

      def exec_prepared(*args)
        Postgres.record(sql: args[0], binds: args[1], source: :exec_prepared) do
          super
        end
      end
    end

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
        Recording.push(sql: sql, binds: binds, result: nil)
        data = Recording.cached_query_for(sql)
        return yield unless data # cache miss

        RecordedResult.new(data['result'].slice('count', 'fields', 'values'))
      else
        yield.tap do |result|
          Recording.push(sql: sql, binds: binds, result: result)
        end
      end
    end

    def setup
      ::PG::Connection.class_eval do
        prepend Recorder
      end
    end
  end
end
