# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    association :author

    title { 'Just a post' }
    description { "Created by #{author.name}" }

    trait :with_author_mat do
      association :author, factory: [:author, :mat]
    end

    factory :invalid_post do
      title { nil }
    end
  end
end
