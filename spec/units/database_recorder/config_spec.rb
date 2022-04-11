# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseRecorder::Config do
  let(:instance) { described_class.instance }
  let(:default_storage) { described_class::DEFAULT_STORAGE }

  describe 'delegation of attributes from the class to the instance' do
    %i[db_driver print_queries replay_recordings storage].each do |attribute|
      before do
        allow(instance).to receive(attribute)
        described_class.send(attribute)
      end

      it { expect(instance).to have_received(attribute) }
    end
  end

  describe '.load_defaults' do
    it do
      expect(described_class).to have_attributes(
        db_driver: described_class::DEFAULT_DB_DRIVER,
        print_queries: false,
        replay_recordings: false,
        storage: default_storage
      )
    end
  end

  describe '.storage=' do
    context 'with nil argument' do
      subject(:set_storage) { described_class.storage = nil }

      it { expect { set_storage }.to change(described_class, :storage).from(default_storage).to(nil) }
    end

    context 'with :redis argument' do
      subject(:set_storage) { described_class.storage = :redis }

      it do
        redis_storage = DatabaseRecorder::Storage::Redis
        expect { set_storage }.to change(described_class, :storage).from(default_storage).to(redis_storage)
      end
    end

    context 'with :file argument' do
      subject(:set_storage) { described_class.storage = :file }

      before { described_class.storage = nil }

      it do
        file_storage = DatabaseRecorder::Storage::File
        expect { set_storage }.to change(described_class, :storage).from(nil).to(file_storage)
      end
    end
  end
end
