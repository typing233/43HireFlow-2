FactoryBot.define do
  factory :note do
    candidate
    user
    body { Faker::Lorem.paragraph }
    private { false }
  end
end
