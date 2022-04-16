# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseRecorder::PG::Recorder, skip: ENV['DB_ADAPTER'] != 'postgresql' do
  describe 'query recording' do
    let(:db_config) do
      {
        host: ENV['DB_HOST'],
        dbname: ENV['DB_NAME'],
        user: ENV['DB_USERNAME'],
        password: ENV['DB_PASSWORD']
      }
    end
    let(:sql) { "SELECT name FROM tags WHERE name = 'tag1'" }
    let(:connection) { PG.connect(db_config) }
    let(:exec_query) { connection.exec(sql) }

    before do
      connection.exec("INSERT INTO tags(name, created_at, updated_at) VALUES('tag1', NOW(), NOW())")
      connection.exec("INSERT INTO tags(name, created_at, updated_at) VALUES('tag2', NOW(), NOW())")
      DatabaseRecorder::Recording.new
      allow(DatabaseRecorder::Recording).to receive(:started?).and_return(true)
      described_class.setup
    end

    after do
      allow(DatabaseRecorder::Config).to receive(:print_queries).and_return(false)
      connection.exec('DELETE FROM tags')
    end

    it 'enqueues a new recording' do
      exec_query
      expect(DatabaseRecorder::Recording.queries).to match_array(
        a_hash_including(sql: sql, result: { count: 1, fields: ['name'], values: [['tag1']] } )
      )
    end

    context 'with config: print_queries = true' do
      before { allow(DatabaseRecorder::Config).to receive(:print_queries).and_return(true) }

      it { expect { exec_query }.to output(a_string_including(sql)).to_stdout }
    end

    context 'with prepared statements' do
      let(:exec_query) do
        connection.prepare('statement1', 'SELECT name FROM tags WHERE name = $1')
        connection.exec_prepared('statement1', ['tag2'])
      end

      it 'enqueues a new recording' do
        exec_query
        expect(DatabaseRecorder::Recording.queries).to match_array(
          a_hash_including(
            name: 'statement1',
            sql: 'SELECT name FROM tags WHERE name = $1',
            result: { count: 1, fields: ['name'], values: [['tag2']] }
          )
        )
      end
    end
  end
end
