# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Database recorder' do
  describe 'YAML output' do
    it 'produces the expected files', :aggregate_failures do
      expected = Dir['spec/dbr_results/*']
      output = Dir['spec/dummy/spec/dbr/*']
      expected_files = expected.map { |file| File.basename(file) }
      output_files = output.map { |file| File.basename(file) }

      expect(output_files).to match_array(expected_files)

      output.each do |file|
        filename = File.basename(file)
        output_data = YAML.load_file(file)

        expected_file = expected.find { |f| f.include? filename }
        expected_data = YAML.load_file(expected_file)

        output_queries = output_data['queries'].map { |item| item.slice('name', 'sql', 'count', 'fields') }
        expected_queries = expected_data['queries'].map { |item| item.slice('name', 'sql', 'count', 'fields') }
        expect(output_queries).to eq(expected_queries)
      end
    end
  end
end
