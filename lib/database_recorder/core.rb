# frozen_string_literal: true

module DatabaseRecorder
  module Core
    module_function

    def log_query(sql, source)
      case DatabaseRecorder::Config.print_queries
      when true
        puts "[DB] #{sql} [#{source}]"
      when :color
        puts "[DB] #{CodeRay.scan(sql, :sql).term} [#{source}]"
      end
    end
  end
end
