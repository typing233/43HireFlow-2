FactoryBot.define do
  factory :team do
    name { Faker::Company.name }
    slug { name.parameterize + "-#{SecureRandom.hex(3)}" }
  end
end
