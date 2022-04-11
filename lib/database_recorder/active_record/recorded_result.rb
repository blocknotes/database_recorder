# frozen_string_literal: true

# require 'forwardable'

module DatabaseRecorder
  module ActiveRecord
    class RecordedResult < ::ActiveRecord::Result
      alias :cmd_tuples :count
      alias :fields :columns
      alias :values :rows

      def clear; end

      def fmod(_index)
        -1
      end

      def ftype(_index)
        20
      end
    end
  end
end
