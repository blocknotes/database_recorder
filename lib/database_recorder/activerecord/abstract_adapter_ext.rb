# frozen_string_literal: true

module DatabaseRecorder
  module ActiveRecord
    module AbstractAdapterExt
      def log(sql, name = 'SQL', binds = [], type_casted_binds = [], *args)
        # puts "--- #{sql} | #{type_casted_binds}", "  > #{name}"
        return super unless Recording.started?
        return super if %w[schema transaction].include?(name&.downcase)
        return super if sql.downcase.match(/\A(begin|commit|release|rollback|savepoint)/i)

        Core.log_query(sql, name)
        if Config.replay_recordings && Recording.from_cache
          Recording.push(sql: sql, binds: binds)
          data = Recording.cached_query_for(sql)
          return yield if !data || !data['result'] # cache miss

          RecordedResult.new(data['result']['fields'], data['result']['values'])
        else
          super.tap do |result|
            result_data =
              if result.is_a?(::ActiveRecord::Result)
                fields = result.respond_to?(:fields) ? result.fields : result.columns
                values = result.respond_to?(:values) ? result.values : result.to_a
                { 'count' => result.count, 'fields' => fields, 'values' => values }
              end
            Recording.push(sql: sql, name: name, binds: type_casted_binds, result: result_data)
          end
        end
      end
    end
  end
end
