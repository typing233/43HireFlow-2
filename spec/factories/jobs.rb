FactoryBot.define do
  factory :job do
    team
    association :creator, factory: :user
    title { Faker::Job.title }
    description { Faker::Lorem.paragraph }
    department { Faker::Commerce.department }
    location { Faker::Address.city }
    employment_type { %w[full_time part_time contract].sample }
    status { "draft" }
    pipeline_version { 1 }

    trait :draft do
      status { "draft" }
    end

    trait :published do
      status { "published" }
      published_at { Time.current }
    end

    trait :closed do
      status { "closed" }
      published_at { 1.week.ago }
      closed_at { Time.current }
    end
  end
end
