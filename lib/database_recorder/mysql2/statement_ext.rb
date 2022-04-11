# frozen_string_literal: true

module DatabaseRecorder
  module Mysql2
    module StatementExt
      def execute(*args, **kwargs)
        Recorder.update_record(self, *args) do
          super
        end
      end
    end
  end
end
