# frozen_string_literal: true

module DatabaseRecorder
  module Core
    module_function

    def log_query(sql, source = nil)
      log =
        case DatabaseRecorder::Config.print_queries
        when true then "[DB] #{sql} [#{source}]"
        when :color then "[DB] #{CodeRay.scan(sql, :sql).term} [#{source}]"
        end

      puts log if log
      log
    end

    def setup
      case DatabaseRecorder::Config.db_driver
      when :active_record then ActiveRecord::Recorder.setup
      when :mysql2 then Mysql2.setup
      when :pg then PG.setup
      end
    end
  end
end
