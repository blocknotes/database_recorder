# frozen_string_literal: true

module DatabaseRecorder
  module ActiveRecord
    module Recorder
      module_function

      def ignore_query?(sql, name)
        !Recording.started? ||
          %w[schema transaction].include?(name&.downcase) ||
          sql.downcase.match?(/\A(begin|commit|release|rollback|savepoint)/i)
      end

      def record(adapter, sql, name = 'SQL', binds = [], type_casted_binds = [], *args)
        return yield if ignore_query?(sql, name)

        Core.log_query(sql, name)
        if Config.replay_recordings && Recording.from_cache
          Recording.push(sql: sql, binds: binds)
          data = Recording.cached_query_for(sql)
          return yield if !data || !data[:result] # cache miss

          RecordedResult.new(data[:result][:fields], data[:result][:values])
        else
          yield.tap do |result|
            result_data =
              if result && (result.respond_to?(:fields) || result.respond_to?(:columns))
                fields = result.respond_to?(:fields) ? result.fields : result.columns
                values = result.respond_to?(:values) ? result.values : result.to_a
                { count: result.count, fields: fields, values: values }
              end
            Recording.push(sql: sql, name: name, binds: type_casted_binds, result: result_data)
          end
        end
      end

      def setup
        ::ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
          prepend AbstractAdapterExt
        end

        # ::ActiveRecord::Base.class_eval do
        #   prepend BaseExt
        # end
      end
    end
  end
end
