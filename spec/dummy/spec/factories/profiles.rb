# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    author { association(:author, profile: instance) }
  end
end
