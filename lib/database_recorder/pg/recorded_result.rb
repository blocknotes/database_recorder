# frozen_string_literal: true

module DatabaseRecorder
  module PG
    class RecordedResult
      attr_reader :count, :fields, :values, :type_map

      alias :cmd_tuples :count
      alias :columns :fields
      alias :ntuples :count
      alias :rows :values

      def initialize(data)
        @count = data[:count]
        @fields = data[:fields]
        @values = data[:values]
      end

      def clear; end

      def first
        to_a.first
      end

      def fmod(_index)
        -1
      end

      def ftype(_index)
        20
      end

      def map_types!(type_map)
        @type_map = type_map
        self
      end

      def nfields
        fields.size
      end

      def to_a
        @to_a ||= values.each_with_object([]) do |value, list|
          list << fields.zip(value).to_h
        end
      end
    end
  end
end
