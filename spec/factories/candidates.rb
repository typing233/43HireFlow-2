FactoryBot.define do
  factory :candidate do
    job
    team
    stage
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.phone_number }
    source { %w[LinkedIn Indeed Referral Direct].sample }
    status { "active" }
    pipeline_version { 1 }
  end
end
