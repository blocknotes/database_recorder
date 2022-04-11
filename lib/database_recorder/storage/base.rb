# frozen_string_literal: true

module DatabaseRecorder
  module Storage
    class Base
      def initialize(recording, name:)
        @recording = recording
        @name = name
      end
    end
  end
end
