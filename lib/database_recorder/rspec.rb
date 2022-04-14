# frozen_string_literal: true

module DatabaseRecorder
  module RSpec
    module_function

    def setup
      ::RSpec.configure do |config|
        config.before(:suite) do
          Core.setup
        end

        config.around(:each, :dbr) do |example|
          ref = (example.metadata[:scoped_id] || '').split(':')[-1]
          options = {}
          options.merge!(example.metadata[:dbr]) if example.metadata[:dbr].is_a?(Hash)
          options.merge!(example: example, name: "#{example.full_description}__#{ref}")
          Recording.new(options: options).tap do |recording|
            recording.metadata = { 'example' => example.id, 'started_at' => Time.now }
            result = recording.start { example.run }
            if options[:verify_queries] && result[:stored_queries]
              expect(result[:stored_queries]).to match_array(result[:current_queries])
            end
          end
        end
      end
    end
  end
end
