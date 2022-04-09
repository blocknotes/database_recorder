# frozen_string_literal: true

module DatabaseRecorder
  module Mysql2
    module ClientExt
      def query(sql, options = {})
        Recorder.record(self, sql: sql) do
          super
        end
      end

      def prepare(*args)
        Recorder.record(self, sql: args[0]) do
          super
        end
      end
    end
  end
end
