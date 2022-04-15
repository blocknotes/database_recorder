# frozen_string_literal: true

module DatabaseRecorder
  module Storage
    class File < Base
      def load
        stored_data = ::File.exist?(storage_path) ? ::File.read(storage_path) : false
        if stored_data
          data = YAML.load(stored_data) # rubocop:disable Security/YAMLLoad
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
        serialized_data = data.to_yaml
        ::File.write(storage_path, serialized_data)
        true
      end

      def storage_path
        @storage_path ||= begin
          name = normalize_name(@name)
          path = @options[:recordings_path] || 'spec/dbr'
          FileUtils.mkdir_p(path)
          "#{path}/#{name}.yml"
        end
      end

      private

      def normalize_name(string)
        string.gsub(%r{[:/]}, '-').gsub(/[^\w-]/, '_')
      end
    end
  end
end
