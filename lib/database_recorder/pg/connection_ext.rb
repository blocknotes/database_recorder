# frozen_string_literal: true

module DatabaseRecorder
  module PG
    module ConnectionExt
      def async_exec(sql)
        Recorder.record(sql: sql, source: :async_exec) do
          super
        end
      end

      def sync_exec(sql)
        Recorder.record(sql: sql, source: :sync_exec) do
          super
        end
      end

      def exec(*args)
        Recorder.record(sql: args[0], source: :exec) do
          super
        end
      end

      def exec_params(*args)
        Recorder.record(sql: args[0], binds: args[1], source: :exec_params) do
          super
        end
      end

      def exec_prepared(*args)
        Recorder.update_record(name: args[0], binds: args[1], source: :exec_prepared) do
          super
        end
      end

      def prepare(*args)
        Recorder.prepare_statement(name: args[0], sql: args[1], source: :prepare) do
          super
        end
      end

      def query(*args)
        Recorder.record(sql: args[0], source: :query) do
          super
        end
      end
    end
  end
end
