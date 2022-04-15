# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseRecorder::Storage::File do
  describe '#load' do
    subject(:load) { file_storage.load }

    let(:file_storage) { described_class.new(recording, name: 'some name') }
    let(:recording) { instance_double(DatabaseRecorder::Recording, :cache= => nil, :entities= => nil) }

    before do
      allow(file_storage).to receive(:storage_path).and_return(file_fixture('sample1.yml').to_s)
    end

    it 'loads data from file', :aggregate_failures do
      test_cache = array_including(
        a_hash_including(
          'binds' => a_kind_of(Array),
          'name' => 'Post Load',
          'result' => a_kind_of(Hash),
          'sql' => 'SELECT "posts".* FROM "posts" WHERE "posts"."id" = $1 LIMIT $2'
        )
      )

      expect(load).to be == true
      expect(recording).to have_received(:cache=).with(test_cache)
      expect(recording).to have_received(:entities=)
    end
  end

  describe '#save' do
    subject(:save) { file_storage.save }

    let(:file_storage) { described_class.new(recording, name: 'some name') }
    let(:recording) do
      instance_double(DatabaseRecorder::Recording, metadata: metadata, queries: queries, entities: entities)
    end
    let(:metadata) { { 'example' => 'some spec path', 'started_at' => Time.now } }
    let(:queries) do
      [{ 'name' => 'Post Load',
         'sql' => 'SELECT "posts".* FROM "posts"',
         'binds' => [],
         'result' => { 'count' => 0, 'fields' => ['id', 'state', 'title', 'description', 'author_id', 'category', 'dt', 'position', 'published', 'created_at', 'updated_at'], 'values' => [] } }]
    end
    let(:entities) { [] }

    before do
      allow(::File).to receive(:write)
    end

    it 'saves data to file', :aggregate_failures do
      data = a_string_including('example: some spec path', 'name: Post Load', 'sql: SELECT "posts".* FROM "posts"')

      expect(save).to be == true
      expect(::File).to have_received(:write).with(file_storage.storage_path, data)
    end
  end

  describe '#storage_path' do
    subject(:storage_path) { described_class.new(recording, name: 'a A1!b#B-_c@C').storage_path }

    let(:recording) { instance_double(DatabaseRecorder::Recording) }

    it 'returns the path to the storage file' do
      expect(storage_path).to eq('spec/dbr/a_A1_b_B-_c_C.yml')
    end
  end
end
