# frozen_string_literal: true

module DatabaseRecorder
  module RSpec
    module_function

    def setup
      ::RSpec.configure do |config|
        config.before(:suite) do
          Postgres.setup
        end

        config.around(:each, :dbr) do |example|
          options = {}
          options.merge!(example.metadata[:dbr]) if example.metadata[:dbr].is_a?(Hash)
          options.merge!(example: example)
          ref = (example.metadata[:scoped_id] || '').split(':')[-1]
          Recording.new(options: options).tap do |recording|
            storage = Config.storage.new(recording, name: "#{example.full_description}__#{ref}")
            cached = storage.load
            recording.start { example.run }
            storage.save unless cached

            if cached && options[:verify_queries]
              stored_queries = recording.cache.map { _1['sql'] }
              current_queries = recording.queries.map { _1['sql'] }
              expect(stored_queries).to match_array(current_queries)
            end
          end
        end
      end
    end
  end
end
