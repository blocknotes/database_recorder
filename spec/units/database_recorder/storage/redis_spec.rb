# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseRecorder::Storage::Redis do
  describe '#connection' do
    subject(:connection) { redis_storage.connection }

    let(:redis_storage) { described_class.new(instance_double(DatabaseRecorder::Recording), name: 'some name') }

    before { allow(::Redis).to receive(:new).and_call_original }

    it 'returns a Redis connection', :aggregate_failures do
      expect(connection).to be_kind_of Redis
      expect(::Redis).to have_received(:new)
    end

    context 'when connection is passed in options' do
      let(:redis_storage) do
        described_class.new(recording, name: 'some name', options: { connection: some_connection })
      end
      let(:recording) { instance_double(DatabaseRecorder::Recording) }
      let(:some_connection) { instance_double(::Redis) }

      it 'returns the connection', :aggregate_failures do
        expect(connection).to eq some_connection
        expect(::Redis).not_to have_received(:new)
      end
    end
  end

  describe '#load' do
    subject(:load) { redis_storage.load }

    let(:redis) { instance_double(::Redis, get: stored_data) }
    let(:redis_storage) { described_class.new(recording, name: 'some name') }
    let(:recording) { instance_double(DatabaseRecorder::Recording, :cache= => nil, :entities= => nil) }
    let(:stored_data) do
      '{"queries":[{"name":"Post Load","sql":"SELECT \"posts\".* FROM \"posts\"","binds":[],"result":{"count":0,"fields":["id","state","title","description","author_id","category","dt","position","published","created_at","updated_at"],"values":[]}}],"entities":[]}'
    end

    before { allow(::Redis).to receive(:new).and_return(redis) }

    it 'loads data from redis', :aggregate_failures do
      test_cache = array_including(
        a_hash_including(
          binds: a_kind_of(Array),
          name: 'Post Load',
          result: a_kind_of(Hash),
          sql: 'SELECT "posts".* FROM "posts"'
        )
      )

      expect(load).to be == true
      expect(redis).to have_received(:get).with('some name')
      expect(recording).to have_received(:cache=).with(test_cache)
      expect(recording).to have_received(:entities=)
    end
  end

  describe '#save' do
    subject(:save) { redis_storage.save }

    let(:redis) { instance_double(::Redis, set: nil) }
    let(:redis_storage) { described_class.new(recording, name: 'some name') }
    let(:recording) do
      instance_double(DatabaseRecorder::Recording, metadata: metadata, queries: queries, entities: [])
    end
    let(:metadata) { { 'example' => 'some spec path', 'started_at' => Time.now } }
    let(:queries) do
      [{ 'name' => 'Post Load',
         'sql' => 'SELECT "posts".* FROM "posts"',
         'binds' => [],
         'result' => { 'count' => 0, 'fields' => ['id', 'state', 'title', 'description', 'author_id', 'category', 'dt', 'position', 'published', 'created_at', 'updated_at'], 'values' => [] } }]
    end

    before { allow(::Redis).to receive(:new).and_return(redis) }

    it 'saves data to redis', :aggregate_failures do
      data = a_string_including('some spec path', 'Post Load')

      expect(save).to be == true
      expect(redis).to have_received(:set).with('some name', data)
    end
  end
end
