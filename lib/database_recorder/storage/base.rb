# frozen_string_literal: true

module DatabaseRecorder
  module Storage
    class Base
      def initialize(recording, name:, options: {})
        @recording = recording
        @name = name
        @options = options
      end
    end
  end
end
