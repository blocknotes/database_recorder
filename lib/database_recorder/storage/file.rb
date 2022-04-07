# frozen_string_literal: true

module DatabaseRecorder
  module Storage
    class File
      def initialize(recording, name:)
        @recording = recording
        @name = name
      end

      def load
        stored_data = ::File.exist?(record_file) ? ::File.read(record_file) : false
        if stored_data
          data = YAML.load(stored_data)
          @recording.cache = data['queries']
          @recording.entities = data['entities']
          true
        else
          false
        end
      end

      def save
        data = { 'queries' => @recording.queries }
        data['entities'] = @recording.entities if @recording.entities.any?
        serialized_data = data.to_yaml
        ::File.write(record_file, serialized_data)
      end

      private

      def normalize_name(string)
        string.gsub(%r{[:/]}, '-').gsub(/[^\w-]/, '_')
      end

      def record_file
        name = normalize_name(@name)
        path = 'spec/dbr'
        FileUtils.mkdir_p(path)
        "#{path}/#{name}.yml"
      end
    end
  end
end
