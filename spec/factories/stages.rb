FactoryBot.define do
  factory :stage do
    job
    name { Faker::Lorem.word.capitalize }
    position { 0 }
    pipeline_version { 1 }
    active { true }
  end
end
