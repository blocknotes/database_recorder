# frozen_string_literal: true

module DatabaseRecorder
  module Core
    module_function

    def log_query(sql, source = nil)
      log =
        case DatabaseRecorder::Config.print_queries
        when true
          DatabaseRecorder::Config.log_format.sub('%name', source.to_s).sub('%sql', sql)
        when :color
          code_ray_sql = CodeRay.scan(sql, :sql).term
          DatabaseRecorder::Config.log_format.sub('%name', source.to_s).sub('%sql', code_ray_sql || '')
        end

      puts log if log
      log
    end

    def setup
      case DatabaseRecorder::Config.db_driver
      when :active_record then ActiveRecord::Recorder.setup
      when :mysql2 then Mysql2::Recorder.setup
      when :pg then PG::Recorder.setup
      end
    end

    def string_keys_recursive(hash)
      {}.tap do |h|
        hash.each do |key, value|
          h[key.to_s] = transform(value, :string_keys_recursive)
        end
      end
    end

    def symbolize_recursive(hash)
      {}.tap do |h|
        hash.each do |key, value|
          h[key.to_sym] = transform(value, :symbolize_recursive)
        end
      end
    end

    def transform(value, source_method)
      case value
      when Hash then method(source_method).call(value)
      when Array then value.map { |v| transform(v, source_method) }
      else value
      end
    end
  end
end
