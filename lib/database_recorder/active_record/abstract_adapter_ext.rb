# frozen_string_literal: true

module DatabaseRecorder
  module ActiveRecord
    module AbstractAdapterExt
      def log(*args)
        Recorder.record(self, *args) do
          super
        end
      end
    end
  end
end
