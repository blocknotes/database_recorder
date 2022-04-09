# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseRecorder::Core do
  describe '.log_query' do
    subject(:log_query) { described_class.log_query(sql, source) }

    let(:sql) { 'SELECT * FROM some_table' }
    let(:source) { 'some_source' }

    context 'with config: print_queries = true' do
      before { DatabaseRecorder::Config.print_queries = true }

      it { expect { log_query }.to output(include(sql, source)).to_stdout }
    end

    context 'with config: print_queries = :color' do
      before do
        allow(CodeRay).to receive_message_chain(:scan, :term)
        DatabaseRecorder::Config.print_queries = :color
      end

      it 'calls CodeRay for printing the query', :aggregate_failures do
        expect { log_query }.to output(include(source)).to_stdout
        expect(CodeRay).to have_received(:scan)
      end
    end
  end

  describe '.setup' do
    subject(:setup) { described_class.setup }

    before do
      allow(DatabaseRecorder::ActiveRecord::Recorder).to receive(:setup)
      allow(DatabaseRecorder::Mysql2).to receive(:setup)
      allow(DatabaseRecorder::PG).to receive(:setup)
    end

    context 'with config: db_driver = :active_record' do
      before do
        DatabaseRecorder::Config.db_driver = :active_record
        setup
      end

      it 'calls the ActiveRecord setup method', :aggregate_failures do
        expect(DatabaseRecorder::ActiveRecord::Recorder).to have_received(:setup)
        expect(DatabaseRecorder::Mysql2).not_to have_received(:setup)
        expect(DatabaseRecorder::PG).not_to have_received(:setup)
      end
    end

    context 'with config: db_driver = :mysql2' do
      before do
        DatabaseRecorder::Config.db_driver = :mysql2
        setup
      end

      it 'calls the Mysql2 setup method', :aggregate_failures do
        expect(DatabaseRecorder::ActiveRecord::Recorder).not_to have_received(:setup)
        expect(DatabaseRecorder::Mysql2).to have_received(:setup)
        expect(DatabaseRecorder::PG).not_to have_received(:setup)
      end
    end

    context 'with config: db_driver = :pg' do
      before do
        DatabaseRecorder::Config.db_driver = :pg
        setup
      end

      it 'calls the PG setup method', :aggregate_failures do
        expect(DatabaseRecorder::ActiveRecord::Recorder).not_to have_received(:setup)
        expect(DatabaseRecorder::Mysql2).not_to have_received(:setup)
        expect(DatabaseRecorder::PG).to have_received(:setup)
      end
    end
  end
end
