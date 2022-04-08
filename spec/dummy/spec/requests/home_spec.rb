# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'posts API', :dbr, type: :request do
  let(:response_body) { JSON.parse(response.body) }

  describe 'GET /', :dbr do
    context 'without posts' do
      before { get '/' }

      it { expect(response.status).to eq 200 }

      it { expect(response_body).to be_empty }
    end

    context 'with some posts', dbr: { name: 'posts_api' } do
      let!(:post1) { create(:post) }
      let!(:post2) { create(:post) }

      before { get '/' }

      it { expect(response.status).to eq 200 }

      it { expect(response_body.count).to eq 2 }

      it 'returns 2 posts' do
        expect(response_body.pluck('id')).to eq [post1.id, post2.id]
      end
    end
  end
end
