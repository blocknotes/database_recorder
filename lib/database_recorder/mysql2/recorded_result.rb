# frozen_string_literal: true

# require 'forwardable'

module DatabaseRecorder
  module Mysql2
    class RecordedResult < ::Mysql2::Result
      # include Enumerable
      # extend Forwardable

      # def_delegators :to_a, :each

      attr_reader :count, :fields, :values

      alias :size :count

      def prepare(data)
        @count = data['count']
        @fields = data['fields']
        @values = data['values']
      end

      # def server_flags
      #   { no_good_index_used: false, no_index_used: true, query_was_slow: false }
      # end

      # def to_a
      #   @to_a ||= values.each_with_object([]) do |value, list|
      #     list << fields.zip(value).to_h
      #   end
      # end
    end
  end
end
