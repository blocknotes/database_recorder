# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatabaseRecorder::RSpec do
  describe '.setup' do
    subject(:setup) { described_class.setup }

    let(:config) { instance_double(::RSpec::Core::Configuration, around: nil, before: nil) }

    before do
      allow(::RSpec).to receive(:configure).and_yield(config)
    end

    it 'configures DatabaseRecorder with RSpec', :aggregate_failures do
      setup
      expect(::RSpec).to have_received(:configure)
      expect(config).to have_received(:before).with(:suite)
      expect(config).to have_received(:around).with(:each, :dbr)
    end
  end
end
