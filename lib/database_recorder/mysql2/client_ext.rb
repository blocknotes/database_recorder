# frozen_string_literal: true

module DatabaseRecorder
  module Mysql2
    module ClientExt
      def query(sql, options = {})
        Recorder.store_query(self, sql: sql, source: :query) do
          super
        end
      end

      def prepare(*args)
        Recorder.prepare_statement(self, sql: args[0], source: :prepare) do
          super
        end
      end
    end
  end
end
