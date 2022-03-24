# frozen_string_literal: true

module DatabaseRecorder
  module Storage
    class File
      def initialize(recording, name:)
        @recording = recording
        @name = name
      end

      def load
        data = ::File.exist?(record_file) ? ::File.read(record_file) : false
        if data
          @recording.cache = YAML.load(data)
          true
        else
          false
        end
      end

      def save
        data = @recording.queries.to_yaml
        ::File.write(record_file, data)
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
