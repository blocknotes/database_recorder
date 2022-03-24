# frozen_string_literal: true

module DatabaseRecorder
  module Storage
    class Redis
      def initialize(recording, name:)
        @recording = recording
        @name = name
      end

      def load
        data = self.class.connection.get(@name)
        if data
          @recording.cache = JSON.parse(data)
          true
        else
          false
        end
      end

      def save
        data = @recording.queries.to_json
        self.class.connection.set(@name, data)
      end

      class << self
        def connection
          @connection ||= ::Redis.new
        end
      end
    end
  end
end
