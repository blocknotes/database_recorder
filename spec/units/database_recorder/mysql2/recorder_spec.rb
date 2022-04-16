# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseRecorder::Mysql2::Recorder, skip: ENV['DB_ADAPTER'] != 'mysql2' do
  describe 'query recording' do
    let(:db_config) do
      {
        host: ENV['DB_HOST'],
        database: ENV['DB_NAME'],
        username: ENV['DB_USERNAME'],
        password: ENV['DB_PASSWORD']
      }
    end
    let(:sql) { "SELECT name FROM tags WHERE name = 'tag1'" }
    let(:client) { ::Mysql2::Client.new(db_config) }
    let(:exec_query) { client.query(sql) }

    before do
      client.query("INSERT INTO tags(name, created_at, updated_at) VALUES('tag1', NOW(), NOW())")
      client.query("INSERT INTO tags(name, created_at, updated_at) VALUES('tag2', NOW(), NOW())")
      DatabaseRecorder::Recording.new
      allow(DatabaseRecorder::Recording).to receive(:started?).and_return(true)
      described_class.setup
    end

    after do
      allow(DatabaseRecorder::Config).to receive(:print_queries).and_return(false)
      client.query('DELETE FROM tags')
    end

    it 'enqueues a new recording' do
      test_queries = a_hash_including(
        sql: sql,
        result: { count: 1, fields: ['name'], values: [{ 'name' => 'tag1' }] }
      )

      exec_query
      expect(DatabaseRecorder::Recording.queries).to match_array(test_queries)
    end

    context 'with config: print_queries = true' do
      before do
        allow(DatabaseRecorder::Config).to receive(:print_queries).and_return(true)
      end

      it { expect { exec_query }.to output(a_string_including(sql)).to_stdout }
    end

    context 'with prepared statements' do
      let(:exec_query) do
        statement = ::Mysql2::Client.new(db_config).prepare('SELECT name FROM tags WHERE name = ?')
        statement.execute('tag2')
      end

      before do
        DatabaseRecorder::Recording.new
        allow(DatabaseRecorder::Recording).to receive(:started?).and_return(true)
        described_class.setup
      end

      it 'enqueues a new recording' do
        test_queries = a_hash_including(
          sql: 'SELECT name FROM tags WHERE name = ?',
          binds: ['tag2'],
          result: { count: 1, fields: ['name'], values: [{ 'name' => 'tag2' }] }
        )

        exec_query
        expect(DatabaseRecorder::Recording.queries).to match_array(test_queries)
      end
    end
  end
end
