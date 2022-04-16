# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseRecorder::Recording do
  describe '#start' do
    before { DatabaseRecorder::Config.storage = nil }

    context 'with some queries' do
      subject(:start) do
        instance.start do
          # some block
        end
      end

      let(:instance) { described_class.new }

      before do
        queries = YAML.load_file('spec/fixtures/queries.yml')
        query = DatabaseRecorder::Core.symbolize_recursive(queries['sample1'])
        allow(instance).to receive(:queries).and_return([query])
      end

      it { is_expected.to eq(current_queries: ['SELECT "posts".* FROM "posts"']) }
    end
  end

  describe '.current_instance' do
    subject(:current_instance) { described_class.current_instance }

    let(:instance) { described_class.new }

    before do
      instance
      allow(Process).to receive(:pid).and_call_original
    end

    it 'returns the instance related to the current process ID', :aggregate_failures do
      expect(current_instance).to eq instance
      expect(Process).to have_received(:pid)
    end
  end

  describe '.started?' do
    subject(:started?) { described_class.started? }

    context 'when there is no instance' do
      before { allow(Process).to receive(:pid).and_return(0) }

      it { is_expected.to be_nil }
    end

    context 'when there is an instance' do
      let(:instance) { described_class.new }

      before do
        instance
        allow(instance).to receive(:started)
      end

      it 'delegates to the current instance', :aggregate_failures do
        started?
        expect(instance).to have_received(:started)
      end
    end
  end
end
