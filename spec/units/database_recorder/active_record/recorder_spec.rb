# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseRecorder::ActiveRecord::Recorder, skip: ENV['DB_ADAPTER'] != 'active_record' do
  describe 'query recording' do
    before do
      create_list(:post, 3)
      allow(DatabaseRecorder::Recording).to receive_messages(push: nil, started?: true)
      described_class.setup
    end

    it 'enqueues a new recording' do
      Post.count
      expected_args = hash_including(
        sql: a_string_matching(/SELECT COUNT.*FROM.*posts/),
        result: { 'count' => 1, 'fields' => ['count'], 'values' => [[3]] }
      )
      expect(DatabaseRecorder::Recording).to have_received(:push).with(expected_args)
    end

    context 'with config: print_queries = true' do
      before do
        allow(DatabaseRecorder::Config).to receive(:print_queries).and_return(true)
      end

      it { expect { Post.count }.to output(a_string_matching(/SELECT COUNT.*FROM.*posts/)).to_stdout }
    end
  end
end
