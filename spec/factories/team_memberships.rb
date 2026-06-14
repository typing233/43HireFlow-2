FactoryBot.define do
  factory :team_membership do
    user
    team
    role { "member" }

    trait :admin do
      role { "admin" }
    end

    trait :owner do
      role { "owner" }
    end
  end
end
