# frozen_string_literal: true

module DatabaseRecorder
  module Storage
    class Redis < Base
      def connection
        @connection ||= @options[:connection] || ::Redis.new
      end

      def load
        stored_data = connection.get(@name)
        if stored_data
          parsed_data = JSON.parse(stored_data)
          data = Core.symbolize_recursive(parsed_data)
          @recording.cache = data[:queries] || []
          @recording.entities = data[:entities]
          true
        else
          false
        end
      end

      def save
        data = {}
        data[:metadata] = @recording.metadata unless @recording.metadata.empty?
        data[:queries] = @recording.queries if @recording.queries.any?
        data[:entities] = @recording.entities if @recording.entities.any?
        serialized_data = data.to_json
        connection.set(@name, serialized_data)
        true
      end
    end
  end
end
