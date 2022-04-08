# frozen_string_literal: true

FactoryBot.define do
  factory :author do
    profile { association(:profile, author: instance) }

    name { 'John' }
    age { 20 }
    email { 'some@email.com' }

    trait :mat do
      name { 'Mat' }
      age { 30 }
      email { 'aaa@bbb.ccc' }
    end

    trait :nick do
      name { 'Nick' }
      age { 32 }
      email { 'eee@fff.ggg' }
    end

    factory :invalid_author do
      name { 'Joy' }
      age { 25 }
    end
  end
end
