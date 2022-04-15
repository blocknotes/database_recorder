# frozen_string_literal: true

module DatabaseRecorder
  module Storage
    class Redis < Base
      def load
        stored_data = self.class.connection.get(@name)
        if stored_data
          data = JSON.parse(stored_data)
          @recording.cache = data['queries'] || []
          @recording.entities = data['entities']
          true
        else
          false
        end
      end

      def save
        data = {}
        data['metadata'] = @recording.metadata unless @recording.metadata.empty?
        data['queries'] = @recording.queries if @recording.queries.any?
        data['entities'] = @recording.entities if @recording.entities.any?
        serialized_data = data.to_json
        self.class.connection.set(@name, serialized_data)
        true
      end

      class << self
        def connection
          ::Redis.new
        end
      end
    end
  end
end
